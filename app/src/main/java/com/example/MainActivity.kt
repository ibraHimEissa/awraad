package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.ViewModelProvider
import com.example.data.db.AppDatabase
import com.example.data.repository.BookRepository
import com.example.ui.ReaderScreen
import com.example.ui.viewmodel.BookViewModel
import com.example.ui.viewmodel.BookViewModelFactory

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Full Edge-to-Edge window insets compliance
        enableEdgeToEdge()

        // 1. Core Model-Layer Initialization (Room DB & repository)
        val database = AppDatabase.getDatabase(this)
        val repository = BookRepository(database.appDao())

        // 2. ViewModel controller initialization using modern ViewModel Factory pattern
        val viewModelFactory = BookViewModelFactory(repository)
        val viewModel = ViewModelProvider(this, viewModelFactory)[BookViewModel::class.java]

        setContent {
            // 3. UI Reader Screen entry point
            ReaderScreen(
                viewModel = viewModel,
                context = applicationContext
            )
        }
    }
}
