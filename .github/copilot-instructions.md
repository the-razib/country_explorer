# GitHub Copilot Instructions for Flutter Development

## 🎯 General Development Philosophy
- Write code as if you're a junior developer - prioritize clarity over cleverness
- Focus on simplicity and readability
- Use straightforward solutions that are easy to understand
- Avoid clever tricks or overly complex abstractions
- Aim for code that is easy to maintain and extend

- Follow clean code principles with simple, readable solutions
- Avoid over-engineering or complex abstractions
- Prefer explicit code over implicit magic

## 🏗️ Architecture Pattern
- **Follow MVC Pattern strictly**
  - **Model**: Data classes, API models, database entities
  - **View**: UI widgets and screens
  - **Controller**: Business logic, state management, API calls

if you generate any new .md files, please ensure they are placed in the correct directories:
- Place documentation files in `documentation/`

## 📁 Project Structure
```
lib/
│-- Auth/
│   ├── controllers/
│   ├── models/
│   ├── views/
│   │   ├── screens/
│   │   └── widgets/
├── Home/
│   ├── controllers/
│   ├── models/
│   ├── views/
│   │   ├── screens/
│   │   └── widgets/
├── services/
├── utils/
└── main.dart
```

## 🎨 Widget Organization
- **Always extract reusable widgets** into separate files
- Place custom widgets in `lib/views/widgets/` folder
- Use descriptive widget names (e.g., `CustomAppBarWidget`, `ProductCardWidget`)
- Keep widget files focused on single responsibility

## 📝 Commenting Standards
- Add comments for **main functionality and business logic**
- Comment complex algorithms or non-obvious code
- Use `//` for single-line comments
- Use `///` for documentation comments on classes and methods
- Comment format:
```dart
/// Description of what this method does
/// [parameter] - Description of parameter
/// Returns: Description of return value
```

## 🔧 Code Style Guidelines

### Variables and Naming
- Use descriptive variable names (`userEmail` not `e`)
- Use camelCase for variables and methods
- Use PascalCase for classes and widgets
- Use UPPER_CASE for constants

### Widget Construction
```dart
// ✅ Good - Clean and readable
class CustomButton extends StatelessWidget {
  /// Custom button widget with rounded corners
  /// [onPressed] - Callback function when button is pressed
  /// [text] - Button text to display
  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }
}
```

### Method Structure
- Keep methods short (max 20-30 lines)
- Use early returns to reduce nesting
- Extract complex logic into separate methods

```dart
// ✅ Good - Simple and clear
Future<void> loadUserData() async {
  // Show loading indicator
  setState(() => isLoading = true);
  
  try {
    // Fetch user data from API
    final userData = await userService.getCurrentUser();
    
    // Update UI with user data
    setState(() {
      user = userData;
      isLoading = false;
    });
  } catch (error) {
    // Handle error and hide loading
    setState(() => isLoading = false);
    _showErrorMessage(error.toString());
  }
}
```

## 🗂️ File Organization Rules

### Controllers
```dart
// user_controller.dart
class UserController {
  /// Manages user-related business logic
  /// Handles API calls and data transformation
  
  // Simple, focused methods
  Future<User> getUserById(String id) async { }
  Future<void> updateUser(User user) async { }
}
```

### Models
```dart
// user_model.dart
class User {
  /// User data model
  /// Contains user information and serialization methods
  
  final String id;
  final String name;
  final String email;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
  });
  
  // Simple factory constructor
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
```

## 🎯 Specific Instructions for Copilot

### When generating Flutter code:
1. **Always suggest widget extraction** if a widget becomes complex
2. **Add meaningful comments** for business logic
3. **Use simple state management** (setState, Getx, Provider) - avoid complex patterns
4. **Avoid deep nesting** - keep widget trees flat and readable
5. **Avoid complex one-liners** - break them into multiple readable lines
6. **Create separate files** for custom widgets
7. **Follow error handling patterns** with try-catch blocks
8. **Use async/await** instead of .then() for promises
9. **Avoid using `var`** - prefer explicit types
10. **Use `const` constructors** where possible to improve performance
11. **Use `final` for variables** that won't change after initialization
12. **Use `??` and `?.` operators** for null safety checks
13. **Avoid using `dynamic` types** - prefer specific types
14. **Use `async` and `await`** for asynchronous operations
15. **Use `Future<void>`** for methods that don't return a value
16. **Use `Stream` for real-time data** updates instead of polling
17. **Use Logger** for logging instead of print statements
18. **Use EasyLoading** for loading states instead snackbar or CircularProgressIndicator.

### Api Calling Rules:
- Use ApiConstants class for api constants
- Use Getx for state management
- Use dio for api calling
- Use try catch for error handling
- Use Logger for logging
- Use EasyLoading for loading states
- Use Getx for navigation
- Avoid complex api calling
- don't show any api response error message in ui shows proper error message and showing error in logger
- Always create model class with null safety 


### Code Generation Preferences:
- Prefer `Column` and `Row` over complex layouts initially
- Use `Container` with explicit properties rather than shortcuts
- Always include `Key? key` parameter in custom widgets
- Use `const` constructors where possible
- Include null safety checks (`??`, `?.`)

### Avoid These Patterns:
- ❌ Complex nested ternary operators
- ❌ Anonymous functions for complex logic
- ❌ Deeply nested widgets (more than 4 levels)
- ❌ Magic numbers or strings (use constants)
- ❌ Overly clever one-liners
- ❌ Using `dynamic` types
- ❌ Using `var` for variable declarations
- ❌ Using `print` for debugging (use Logger instead)


### Widget Extraction Example:
```dart
// ❌ Don't keep complex widgets inline
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // 50+ lines of complex widget code here
      ],
    ),
  );
}

// ✅ Extract to separate widget file
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        const UserProfileHeaderWidget(),
        const UserActionButtonsWidget(),
      ],
    ),
  );
}
```



## 🚀 Remember
- **Clarity over cleverness** - junior developers should understand the code
- **One responsibility per file/class/method**
- **Comment the business logic, not the obvious**
- **Extract widgets early and often**
- **Keep it simple, stupid (KISS principle)**