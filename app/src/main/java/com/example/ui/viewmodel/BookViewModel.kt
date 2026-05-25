package com.example.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.data.BookData
import com.example.data.TocSection
import com.example.data.model.Bookmark
import com.example.data.repository.BookRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay
import kotlinx.coroutines.Job

class BookViewModel(private val repository: BookRepository) : ViewModel() {

    // Theme state (default dark = true)
    private val _isDarkMode = MutableStateFlow(true)
    val isDarkMode: StateFlow<Boolean> = _isDarkMode.asStateFlow()

    // Current page: 1-indexed (1 to 137)
    private val _currentPage = MutableStateFlow(1)
    val currentPage: StateFlow<Int> = _currentPage.asStateFlow()

    // Search Query State
    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    // Filtered search results matching TOC sections
    val searchResults: StateFlow<List<TocSection>> = _searchQuery
        .map { query ->
            if (query.isBlank()) {
                emptyList()
            } else {
                BookData.TABLE_OF_CONTENTS.filter {
                    it.title.contains(query, ignoreCase = true)
                }
            }
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // All Bookmarks List Flow
    val bookmarks: StateFlow<List<Bookmark>> = repository.allBookmarks
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // Current page isBookmarked Flow
    val isCurrentPageBookmarked: StateFlow<Boolean> = _currentPage
        .flatMapLatest { page -> repository.isBookmarked(page) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), false)

    // User Toast Feedback (for startup resume loading)
    private val _toastMessage = MutableStateFlow<String?>(null)
    val toastMessage: StateFlow<String?> = _toastMessage.asStateFlow()

    // Dialog & UI Visibility states
    val isJumpDialogVisible = MutableStateFlow(false)
    val isTOCDrawerVisible = MutableStateFlow(false)
    val isSearchDialogVisible = MutableStateFlow(false)

    init {
        // Load initial theme and last read page
        viewModelScope.launch {
            repository.getThemeModeFlow().firstOrNull()?.let { savedTheme ->
                _isDarkMode.value = savedTheme == "dark"
            }
            repository.getLastPageFlow().firstOrNull()?.let { savedPageStr ->
                savedPageStr.toIntOrNull()?.let { savedPage ->
                    if (savedPage in 1..137) {
                        _currentPage.value = savedPage
                        // Format page number in Arabic digits for toast
                        val arabicPage = toArabicNumerals(savedPage)
                        _toastMessage.value = "استأنفت من صفحة $arabicPage"
                    }
                }
            }
        }
    }

    fun toggleTheme() {
        viewModelScope.launch {
            val nextModeInput = !_isDarkMode.value
            _isDarkMode.value = nextModeInput
            repository.saveThemeMode(nextModeInput)
        }
    }

    fun jumpToPage(page: Int) {
        if (page in 1..137) {
            _currentPage.value = page
            saveLastReadPage(page)
        }
    }

    // Toggle bookmark on current page
    fun toggleBookmark() {
        val page = _currentPage.value
        val section = BookData.getSectionForPage(page)
        viewModelScope.launch {
            if (isCurrentPageBookmarked.value) {
                repository.removeBookmark(page)
            } else {
                repository.addBookmark(page, section.title)
            }
        }
    }

    fun removeBookmark(page: Int) {
        viewModelScope.launch {
            repository.removeBookmark(page)
        }
    }

    fun updateSearchQuery(query: String) {
        _searchQuery.value = query
    }

    fun clearToast() {
        _toastMessage.value = null
    }

    private var saveJob: Job? = null

    private fun saveLastReadPage(page: Int) {
        saveJob?.cancel()
        saveJob = viewModelScope.launch {
            delay(500)
            repository.saveLastPage(page)
        }
    }

    // Helper function to translate page numbers into Arabic digits
    fun toArabicNumerals(number: Int): String {
        val arabicChars = charArrayOf('٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩')
        return number.toString().map { char ->
            if (char.isDigit()) arabicChars[char - '0'] else char
        }.joinToString("")
    }
}

class BookViewModelFactory(private val repository: BookRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(BookViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return BookViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
