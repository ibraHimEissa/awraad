package com.example.data.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.data.model.Bookmark
import com.example.data.model.Setting
import kotlinx.coroutines.flow.Flow

@Dao
interface AppDao {
    // Bookmarks queries
    @Query("SELECT * FROM bookmarks ORDER BY page ASC")
    fun getAllBookmarks(): Flow<List<Bookmark>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertBookmark(bookmark: Bookmark)

    @Query("DELETE FROM bookmarks WHERE page = :page")
    suspend fun deleteBookmarkByPage(page: Int)

    @Query("SELECT EXISTS(SELECT 1 FROM bookmarks WHERE page = :page)")
    fun isBookmarked(page: Int): Flow<Boolean>

    // Settings queries
    @Query("SELECT value FROM settings WHERE `key` = :key")
    suspend fun getSetting(key: String): String?

    @Query("SELECT value FROM settings WHERE `key` = :key")
    fun getSettingFlow(key: String): Flow<String?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSetting(setting: Setting)
}
