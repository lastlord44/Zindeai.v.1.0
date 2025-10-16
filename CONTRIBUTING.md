# 🤝 Contributing to ZindeAI

Thank you for your interest in contributing to ZindeAI! This document provides guidelines and information for developers who want to help improve the project.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Code Style Guidelines](#code-style-guidelines)
- [Project Structure](#project-structure)
- [Areas Needing Help](#areas-needing-help)
- [Bug Reports](#bug-reports)
- [Feature Requests](#feature-requests)
- [Pull Request Process](#pull-request-process)

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:

- **Flutter 3.x** installed and configured
- **Dart 3.x** 
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control
- Basic understanding of **Clean Architecture** and **BLoC Pattern**

### Quick Start

1. **Fork the repository**
2. **Clone your fork:**
   ```bash
   git clone https://github.com/yourusername/Zindeai.v.1.0.git
   cd Zindeai.v.1.0
   ```
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Generate code:**
   ```bash
   flutter packages pub run build_runner build
   ```
5. **Run the app:**
   ```bash
   flutter run
   ```

## 🛠️ Development Setup

### Environment Setup

1. **Create a development branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Install development dependencies:**
   ```bash
   flutter pub get
   flutter packages pub run build_runner build
   ```

3. **Run tests:**
   ```bash
   flutter test
   ```

### IDE Configuration

**VS Code Settings:**
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 120,
  "editor.formatOnSave": true,
  "dart.previewFlutterUiGuides": true
}
```

**Android Studio:**
- Install Flutter and Dart plugins
- Configure Flutter SDK path
- Enable format on save

## 📝 Code Style Guidelines

### Dart/Flutter Style

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and [Flutter Style Guide](https://docs.flutter.dev/development/tools/formatting).

**Key Points:**
- Use `camelCase` for variables and functions
- Use `PascalCase` for classes
- Use `snake_case` for file names
- Maximum line length: 120 characters
- Use meaningful names

### Example Code Style

```dart
// ✅ Good
class MealPlanService {
  Future<List<Meal>> getMealsForDate(DateTime date) async {
    // Implementation
  }
}

// ❌ Bad
class mealplanservice {
  Future<List<Meal>> getmealsfordate(DateTime d) async {
    // Implementation
  }
}
```

### Architecture Guidelines

**Clean Architecture Layers:**

```dart
// Domain Layer (Business Logic)
lib/domain/
├── entities/          # Core business objects
├── usecases/          # Business logic
└── repositories/      # Abstract interfaces

// Data Layer (Implementation)
lib/data/
├── models/            # Data models
├── datasources/       # Data sources
└── repositories/      # Repository implementations

// Presentation Layer (UI)
lib/presentation/
├── pages/             # Screen widgets
├── widgets/           # Reusable widgets
└── bloc/              # State management
```

**BLoC Pattern:**
```dart
// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class LoadHomePage extends HomeEvent {
  @override
  List<Object?> get props => [];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeLoaded extends HomeState {
  final List<Meal> meals;
  
  const HomeLoaded({required this.meals});
  
  @override
  List<Object?> get props => [meals];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomePage>(_onLoadHomePage);
  }
  
  Future<void> _onLoadHomePage(
    LoadHomePage event,
    Emitter<HomeState> emit,
  ) async {
    // Implementation
  }
}
```

## 🏗️ Project Structure

### Core Components

```
lib/
├── core/
│   ├── services/          # External services (AI, API)
│   ├── utils/             # Utility functions
│   └── constants/         # App constants
├── data/
│   ├── local/             # Local data sources (Hive)
│   ├── models/            # Data models
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Business entities
│   ├── usecases/          # Business logic
│   └── repositories/       # Repository interfaces
└── presentation/
    ├── pages/              # Screen widgets
    ├── widgets/            # Reusable widgets
    └── bloc/               # State management
```

### Key Files

- **`lib/main.dart`** - App entry point
- **`lib/presentation/pages/home_page.dart`** - Main screen
- **`lib/domain/usecases/ogun_planlayici.dart`** - Genetic algorithm
- **`lib/core/services/pollinations_ai_service.dart`** - AI integration
- **`lib/data/local/hive_service.dart`** - Local storage

## 🎯 Areas Needing Help

### High Priority

1. **Test Coverage** 🔴 CRITICAL
   - Unit tests for genetic algorithm
   - Widget tests for UI components
   - Integration tests for user flows
   - BLoC tests for state management

2. **Bug Fixes** 🟡 IMPORTANT
   - Tolerance system issues
   - AlternatifBesinBottomSheet integration
   - Performance optimizations

3. **Error Handling** 🟡 IMPORTANT
   - Custom exception classes
   - User-friendly error messages
   - Retry mechanisms

### Medium Priority

4. **Documentation** 🟢 NICE TO HAVE
   - API documentation (dartdoc)
   - Architecture diagrams
   - Setup guides

5. **Performance** 🟢 NICE TO HAVE
   - Image caching
   - Pagination for large lists
   - Memory optimization

### Low Priority

6. **Features** 🔵 FUTURE
   - New meal types
   - Workout tracking
   - Social features

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Bug Description** - Clear explanation of the issue
2. **Steps to Reproduce** - Detailed steps to reproduce the bug
3. **Expected Behavior** - What should happen
4. **Actual Behavior** - What actually happens
5. **Environment** - Flutter version, device, OS
6. **Screenshots/Logs** - Visual evidence if applicable

**Bug Report Template:**
```markdown
## Bug Description
Brief description of the bug

## Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
What you expected to happen

## Actual Behavior
What actually happened

## Environment
- Flutter version: 3.x.x
- Dart version: 3.x.x
- Device: Android/iOS
- OS version: ...

## Additional Context
Any other context about the problem
```

## 💡 Feature Requests

When requesting features, please include:

1. **Feature Description** - Clear explanation of the feature
2. **Use Case** - Why this feature is needed
3. **Proposed Solution** - How you think it should work
4. **Alternatives** - Other solutions you've considered

**Feature Request Template:**
```markdown
## Feature Description
Brief description of the feature

## Use Case
Why is this feature needed?

## Proposed Solution
How should this feature work?

## Alternatives
What other solutions have you considered?

## Additional Context
Any other context about the feature request
```

## 🔄 Pull Request Process

### Before Submitting

1. **Run tests:**
   ```bash
   flutter test
   ```

2. **Check code style:**
   ```bash
   flutter analyze
   dart format .
   ```

3. **Update documentation** if needed

4. **Add tests** for new features

### PR Guidelines

1. **Title** - Use clear, descriptive titles
2. **Description** - Explain what changes you made and why
3. **Tests** - Include tests for new features
4. **Documentation** - Update docs if needed
5. **Screenshots** - Include screenshots for UI changes

**PR Template:**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Integration tests pass

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## 🧪 Testing Guidelines

### Unit Tests

Test business logic and use cases:

```dart
// Example: Test genetic algorithm
void main() {
  group('Genetic Algorithm Tests', () {
    test('should create valid meal plan', () async {
      // Arrange
      final algorithm = OgunPlanlayici();
      final targets = MakroHedefleri(/* ... */);
      
      // Act
      final result = await algorithm.gunlukPlanOlustur(
        hedefKalori: targets.gunlukKalori,
        hedefProtein: targets.gunlukProtein,
        hedefKarb: targets.gunlukKarbonhidrat,
        hedefYag: targets.gunlukYag,
      );
      
      // Assert
      expect(result, isA<GunlukPlan>());
      expect(result.toplamKalori, closeTo(targets.gunlukKalori, 50));
    });
  });
}
```

### Widget Tests

Test UI components:

```dart
// Example: Test meal card widget
void main() {
  testWidgets('MealCard displays meal information', (WidgetTester tester) async {
    // Arrange
    final meal = Yemek(/* ... */);
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: OgunCard(yemek: meal),
      ),
    );
    
    // Assert
    expect(find.text(meal.ad), findsOneWidget);
    expect(find.text('${meal.kalori} kcal'), findsOneWidget);
  });
}
```

### Integration Tests

Test complete user flows:

```dart
// Example: Test meal plan generation
void main() {
  testWidgets('User can generate meal plan', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(MyApp());
    
    // Act
    await tester.tap(find.byKey(Key('generate_plan_button')));
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.byType(OgunCard), findsWidgets);
  });
}
```

## 📚 Learning Resources

### Flutter/Dart
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)

### Architecture
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Repository Pattern](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design)

### Testing
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Unit Testing](https://docs.flutter.dev/testing/unit-tests)
- [Widget Testing](https://docs.flutter.dev/testing/widget-tests)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

## 🤔 Questions?

If you have questions about contributing:

1. **Check existing issues** - Your question might already be answered
2. **Create a new issue** - Use the "question" label
3. **Join discussions** - Use GitHub Discussions
4. **Contact maintainers** - Reach out directly

## 🎉 Thank You!

Thank you for contributing to ZindeAI! Your contributions help make the project better for everyone.

---

**Happy Coding! 🚀**



