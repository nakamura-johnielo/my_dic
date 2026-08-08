//word詳細画面
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/app/routing/contracts/route_parse_result.dart';
import 'package:my_dic/app/routing/contracts/word_detail_route.dart';
import 'package:my_dic/app/routing/invalid_route_page.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/word_page/presentation/view/word_page_fragment.dart';

GoRoute wordDetailRoute(String name, {String? parentPath}) => GoRoute(
      path: parentPath == null
          ? WordDetailRoute.path
          : '$parentPath/${WordDetailRoute.path}',
      name: name,
      pageBuilder: (context, state) {
        final result = WordDetailRoute.parse(
          pathParameters: state.pathParameters,
          queryParameters: state.uri.queryParameters,
          parseLegacyType: _catalogIdFromLegacyType,
        );
        return switch (result) {
          RouteParseSuccess(value: final route) =>
            MaterialPage(child: WordPageFragment(route: route)),
          RouteParseFailure(message: final message) =>
            MaterialPage(child: InvalidRoutePage(message: message)),
        };
      },
    );

CatalogId? _catalogIdFromLegacyType(String type) => switch (type) {
      'espJpn' => CatalogId.espJpnMain,
      'jpnEsp' => CatalogId.jpnEspMain,
      _ => null,
    };
