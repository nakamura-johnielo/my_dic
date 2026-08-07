import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test, { after, beforeEach } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  deleteDoc,
  doc,
  getDoc,
  runTransaction,
  serverTimestamp,
  setDoc,
} from 'firebase/firestore';

const projectId = process.env.GCLOUD_PROJECT ?? 'my-dic-sync';
const rules = readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8');
const testEnv = await initializeTestEnvironment({
  projectId,
  firestore: { rules, host: '127.0.0.1', port: 8080 },
});

const ownerId = 'owner';
const otherId = 'other';
const owner = () => testEnv.authenticatedContext(ownerId).firestore();
const other = () => testEnv.authenticatedContext(otherId).firestore();
const anonymous = () => testEnv.unauthenticatedContext().firestore();
const at = (offset = 0) => Timestamp.fromMillis(Date.now() + offset);

function mutationMetadata(revision = 1, mutationId = `mutation-${revision}`) {
  return {
    revision,
    lastMutationId: mutationId,
    clientUpdatedAt: at(1000 + revision),
    updatedAt: serverTimestamp(),
    schemaVersion: 1,
  };
}

function createMutation(identity, fields) {
  return {
    ...identity,
    ...fields,
    createdAt: serverTimestamp(),
    ...mutationMetadata(),
  };
}

function profileProvisioning(uid) {
  return {
    userId: uid,
    userName: 'owner',
    subscriptionStatus: 'free',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    clientUpdatedAt: serverTimestamp(),
    revision: 0,
    lastMutationId: null,
    schemaVersion: 1,
  };
}

const datasetDocuments = (db) => [
  [
    'esp-jpn status',
    doc(db, 'Users', ownerId, 'WordStatus', '1'),
    createMutation({ wordId: 1 }, { isLearned: 1, isBookmarked: 0, hasNote: 0, updateBy: 'test' }),
  ],
  [
    'jpn-esp status',
    doc(db, 'Users', ownerId, 'JpnEspWordStatus', '2'),
    createMutation({ wordId: 2 }, { isLearned: 0, isBookmarked: 1, hasNote: 0, updateBy: 'test' }),
  ],
  [
    'my word',
    doc(db, 'Users', ownerId, 'MyWords', 'word-1'),
    createMutation({ wordId: 'word-1' }, { word: 'hola', contents: 'hello', updateBy: 'test', deletedAt: null }),
  ],
  [
    'my word status',
    doc(db, 'Users', ownerId, 'MyWordStatus', 'word-1'),
    createMutation({ myWordId: 'word-1' }, { isLearned: 0, isBookmarked: 1, updateBy: 'test' }),
  ],
];

beforeEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

test('all five sync datasets allow an owner write and resolve server timestamps', async () => {
  const db = owner();
  const profile = doc(db, 'Users', ownerId);
  await assertSucceeds(setDoc(profile, profileProvisioning(ownerId)));
  for (const [name, reference, data] of datasetDocuments(db)) {
    await assertSucceeds(setDoc(reference, data), name);
    const snapshot = await getDoc(reference);
    assert.equal(snapshot.exists(), true, name);
    assert.ok(snapshot.data().updatedAt instanceof Timestamp, `${name} updatedAt`);
  }

  const profileSnapshot = await getDoc(profile);
  assert.equal(profileSnapshot.exists(), true);
  assert.ok(profileSnapshot.data().updatedAt instanceof Timestamp);
});

test('rules reject anonymous and cross-account reads/writes', async () => {
  const ownedReference = doc(owner(), 'Users', ownerId, 'WordStatus', '1');
  await assertSucceeds(setDoc(ownedReference, datasetDocuments(owner())[0][2]));
  const otherReference = doc(other(), 'Users', ownerId, 'WordStatus', '1');
  const anonymousReference = doc(anonymous(), 'Users', ownerId, 'WordStatus', '1');

  await assertFails(getDoc(otherReference));
  await assertFails(getDoc(anonymousReference));
  await assertFails(setDoc(otherReference, datasetDocuments(other())[0][2]));
});

test('rules reject non-sync fields, authority changes, and hard deletes', async () => {
  const db = owner();
  const profile = doc(db, 'Users', ownerId);
  const status = doc(db, 'Users', ownerId, 'WordStatus', '1');
  await assertSucceeds(setDoc(profile, profileProvisioning(ownerId)));
  await assertSucceeds(setDoc(status, datasetDocuments(db)[0][2]));

  await assertFails(setDoc(status, {
    ...datasetDocuments(db)[0][2],
    injected: true,
  }));
  await assertFails(setDoc(profile, {
    ...profileProvisioning(ownerId),
    subscriptionStatus: 'paid',
  }));
  await assertFails(deleteDoc(status));
});

test('a transaction increases revision and a duplicate mutation leaves it unchanged', async () => {
  const db = owner();
  const status = doc(db, 'Users', ownerId, 'WordStatus', '1');
  await assertSucceeds(setDoc(status, datasetDocuments(db)[0][2]));

  await assertSucceeds(runTransaction(db, async (transaction) => {
    const current = await transaction.get(status);
    transaction.set(status, {
      ...current.data(),
      isLearned: 0,
      ...mutationMetadata(2, 'mutation-2'),
    });
  }));
  const afterUpdate = await getDoc(status);
  assert.equal(afterUpdate.data().revision, 2);
  assert.equal(afterUpdate.data().lastMutationId, 'mutation-2');
  assert.ok(afterUpdate.data().updatedAt instanceof Timestamp);

  // This is the read-before-write duplicate branch used by the production
  // RemoteMutationTransaction: the matching ID is acknowledged without a
  // second write, so its revision and resolved server timestamp stay intact.
  await assertSucceeds(runTransaction(db, async (transaction) => {
    const current = await transaction.get(status);
    if (current.data().lastMutationId === 'mutation-2') return;
    transaction.set(status, {
      ...current.data(),
      ...mutationMetadata(3, 'mutation-2'),
    });
  }));
  const afterDuplicate = await getDoc(status);
  assert.equal(afterDuplicate.data().revision, 2);
  assert.equal(afterDuplicate.data().lastMutationId, 'mutation-2');
});
