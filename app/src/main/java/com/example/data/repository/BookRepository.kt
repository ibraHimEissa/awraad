package com.example.data.repository

import com.example.data.db.AppDao
import com.example.data.model.Bookmark
import com.example.data.model.Setting
import kotlinx.coroutines.flow.Flow

class BookRepository(private val appDao: AppDao) {
    val allBookmarks: Flow<List<Bookmark>> = appDao.getAllBookmarks()

    suspend fun addBookmark(page: Int, sectionTitle: String) {
        appDao.insertBookmark(Bookmark(page = page, sectionTitle = sectionTitle))
    }

    suspend fun removeBookmark(page: Int) {
        appDao.deleteBookmarkByPage(page)
    }

    fun isBookmarked(page: Int): Flow<Boolean> = appDao.isBookmarked(page)

    // Last Page setting helper
    fun getLastPageFlow(): Flow<String?> = appDao.getSettingFlow("last_page")
    suspend fun saveLastPage(page: Int) {
        appDao.insertSetting(Setting("last_page", page.toString()))
    }

    // Theme mode setting helper
    fun getThemeModeFlow(): Flow<String?> = appDao.getSettingFlow("theme_mode")
    suspend fun saveThemeMode(isDark: Boolean) {
        appDao.insertSetting(Setting("theme_mode", if (isDark) "dark" else "light"))
    }
}
