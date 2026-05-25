package com.example

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import com.example.data.db.AppDatabase
import com.example.data.repository.BookRepository
import com.example.ui.viewmodel.BookViewModel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class ExampleRobolectricTest {

  @Test
  fun `read string from context`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val appName = context.getString(R.string.app_name)
    assertEquals("كتاب الأوراد", appName)
  }

  @Test
  fun `verify database and viewmodel initialization`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val database = AppDatabase.getDatabase(context)
    assertNotNull(database)
    
    val repository = BookRepository(database.appDao())
    assertNotNull(repository)
    
    val viewModel = BookViewModel(repository)
    assertNotNull(viewModel)
  }
}
