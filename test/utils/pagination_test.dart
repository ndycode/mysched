import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/utils/pagination.dart';

void main() {
  group('Page', () {
    test('fromList paginates and reports hasMore', () {
      final page = Page<int>.fromList([1, 2, 3, 4], page: 0, pageSize: 3);
      expect(page.items, [1, 2, 3]);
      expect(page.hasMore, isTrue);
      expect(page.totalCount, 4);
      expect(page.totalPages, 2);

      final last = Page<int>.fromList([1, 2, 3, 4], page: 1, pageSize: 3);
      expect(last.items, [4]);
      expect(last.hasMore, isFalse);
    });

    test('empty creates a non-paginated page', () {
      final page = Page<int>.empty(pageSize: 5);
      expect(page.items, isEmpty);
      expect(page.page, 0);
      expect(page.pageSize, 5);
      expect(page.hasMore, isFalse);
      expect(page.totalPages, 0);
    });
  });

  group('PageRequest', () {
    test('derives offset/limit and navigation', () {
      const request = PageRequest(page: 2, pageSize: 10, sortBy: 'due_at');
      expect(request.offset, 20);
      expect(request.limit, 10);
      expect(request.next.page, 3);
      expect(request.previous.page, 1);
      expect(request.sortBy, 'due_at');
    });
  });

  group('InfiniteScrollController', () {
    test('loads successive pages and stops when hasMore is false', () async {
      final controller = InfiniteScrollController<int>(pageSize: 2);
      final requests = <PageRequest>[];

      Future<Page<int>> fetcher(PageRequest request) async {
        requests.add(request);
        final start = request.page * request.pageSize;
        final items = List.generate(request.pageSize, (i) => start + i);
        final hasMore = request.page == 0;
        return Page<int>(
          items: hasMore ? items : [start],
          page: request.page,
          pageSize: request.pageSize,
          totalCount: -1,
          hasMore: hasMore,
        );
      }

      await controller.loadMore(fetcher);
      expect(controller.items, [0, 1]);
      expect(controller.currentPage, 1);
      expect(controller.hasMore, isTrue);

      await controller.loadMore(fetcher);
      expect(controller.items, [0, 1, 2]);
      expect(controller.currentPage, 2);
      expect(controller.hasMore, isFalse);
      expect(requests, hasLength(2));
    });

    test('captures errors and leaves items untouched', () async {
      final controller = InfiniteScrollController<int>(pageSize: 2);

      Future<Page<int>> failing(PageRequest request) async {
        throw Exception('network');
      }

      await controller.loadMore(failing);
      expect(controller.error, contains('network'));
      expect(controller.items, isEmpty);
      expect(controller.isLoading, isFalse);
      expect(controller.hasMore, isTrue);
    });

    test('refresh resets state before loading', () async {
      final controller = InfiniteScrollController<int>(pageSize: 2);

      Future<Page<int>> first(PageRequest request) async {
        return Page<int>(
          items: [1, 2],
          page: request.page,
          pageSize: request.pageSize,
          totalCount: 4,
          hasMore: true,
        );
      }

      await controller.loadMore(first);
      expect(controller.items, [1, 2]);
      expect(controller.hasMore, isTrue);

      Future<Page<int>> second(PageRequest request) async {
        return Page<int>(
          items: [42],
          page: request.page,
          pageSize: request.pageSize,
          totalCount: 1,
          hasMore: false,
        );
      }

      await controller.refresh(second);
      expect(controller.items, [42]);
      expect(controller.hasMore, isFalse);
      expect(controller.currentPage, 1);
    });
  });
}
