package com.example.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "bookmarks")
data class Bookmark(
    @PrimaryKey val page: Int,
    val sectionTitle: String,
    val timestamp: Long = System.currentTimeMillis()
)
