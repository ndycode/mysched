/// Represents a page of data with metadata.
class Page<T> {
  const Page({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.hasMore,
  });

  /// The items in this page.
  final List<T> items;

  /// Current page number (0-indexed).
  final int page;

  /// Number of items per page.
  final int pageSize;

  /// Total count of all items (may be -1 if unknown).
  final int totalCount;

  /// Whether there are more pages available.
  final bool hasMore;

  /// Total number of pages.
  int get totalPages {
    if (totalCount < 0) return -1;
    return (totalCount / pageSize).ceil();
  }

  /// Whether this is the first page.
  bool get isFirst => page == 0;

  /// Whether this is the last page.
  bool get isLast => !hasMore;

  /// Create an empty page.
  factory Page.empty({int pageSize = 20}) {
    return Page(
      items: const [],
      page: 0,
      pageSize: pageSize,
      totalCount: 0,
      hasMore: false,
    );
  }

  /// Create a page from a full list (client-side pagination).
  factory Page.fromList(
    List<T> allItems, {
    required int page,
    int pageSize = 20,
  }) {
    final startIndex = page * pageSize;
    if (startIndex >= allItems.length) {
      return Page(
        items: const [],
        page: page,
        pageSize: pageSize,
        totalCount: allItems.length,
        hasMore: false,
      );
    }

    final endIndex = (startIndex + pageSize).clamp(0, allItems.length);
    return Page(
      items: allItems.sublist(startIndex, endIndex),
      page: page,
      pageSize: pageSize,
      totalCount: allItems.length,
      hasMore: endIndex < allItems.length,
    );
  }
}

/// Request parameters for paginated queries.
class PageRequest {
  const PageRequest({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy,
    this.sortAscending = true,
  });

  /// Page number (0-indexed).
  final int page;

  /// Number of items per page.
  final int pageSize;

  /// Optional field to sort by.
  final String? sortBy;

  /// Sort direction.
  final bool sortAscending;

  /// Offset for database queries.
  int get offset => page * pageSize;

  /// Limit for database queries.
  int get limit => pageSize;

  /// Get the next page request.
  PageRequest get next => PageRequest(
        page: page + 1,
        pageSize: pageSize,
        sortBy: sortBy,
        sortAscending: sortAscending,
      );

  /// Get the previous page request.
  PageRequest get previous => PageRequest(
        page: (page - 1).clamp(0, page),
        pageSize: pageSize,
        sortBy: sortBy,
        sortAscending: sortAscending,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PageRequest &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.sortBy == sortBy &&
        other.sortAscending == sortAscending;
  }

  @override
  int get hashCode => Object.hash(page, pageSize, sortBy, sortAscending);
}

/// Helper for infinite scroll pagination.
class InfiniteScrollController<T> {
  InfiniteScrollController({
    this.pageSize = 20,
  });

  final int pageSize;

  final List<T> _items = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  String? _error;

  /// All loaded items.
  List<T> get items => List.unmodifiable(_items);

  /// Current page number.
  int get currentPage => _currentPage;

  /// Whether more items can be loaded.
  bool get hasMore => _hasMore;

  /// Whether currently loading.
  bool get isLoading => _isLoading;

  /// Last error message, if any.
  String? get error => _error;

  /// Total items loaded so far.
  int get itemCount => _items.length;

  /// Reset the controller.
  void reset() {
    _items.clear();
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
    _error = null;
  }

  /// Load the next page.
  Future<void> loadMore(
    Future<Page<T>> Function(PageRequest request) fetcher,
  ) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;

    try {
      final request = PageRequest(
        page: _currentPage,
        pageSize: pageSize,
      );
      final page = await fetcher(request);
      _items.addAll(page.items);
      _currentPage++;
      _hasMore = page.hasMore;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  /// Refresh from the beginning.
  Future<void> refresh(
    Future<Page<T>> Function(PageRequest request) fetcher,
  ) async {
    reset();
    await loadMore(fetcher);
  }
}


