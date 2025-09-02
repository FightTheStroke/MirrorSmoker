# Contributing to Mirror Smoker 🤝

Thank you for your interest in contributing to Mirror Smoker! This document provides guidelines and information for contributors.

## 🎯 Ways to Contribute

### Code Contributions
- Bug fixes and performance improvements
- New features and enhancements
- UI/UX improvements
- Test coverage improvements
- Documentation updates

### Non-Code Contributions
- Bug reports and feature requests
- Translation and localization
- Documentation improvements
- User experience feedback
- Design suggestions

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ / watchOS 10.0+ development experience
- Familiarity with SwiftUI and SwiftData
- Basic understanding of CloudKit (for sync features)

### Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/mirror-smoker.git
   cd mirror-smoker
   ```

2. **Open in Xcode**
   ```bash
   open MirrorSmokerStopper.xcodeproj
   ```

3. **Configure development team**
   - Select your development team in project settings
   - Update bundle identifiers if needed for testing

4. **Build and test**
   - Build the project (⌘+B)
   - Run tests (⌘+U)
   - Test on device/simulator

## 📋 Development Guidelines

### Code Style
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftUI best practices and modern Swift features
- Prefer Swift Concurrency (async/await) over completion handlers
- Keep files under 250 lines when possible
- Use meaningful variable and function names

### Architecture Patterns
- **MVVM**: Use SwiftUI's built-in patterns with `@State`, `@Observable`, etc.
- **SwiftData**: Use `@Query` and `@Model` for data management
- **Design System**: Use the existing `DS` (Design System) components
- **Localization**: All user-facing strings must be localized

### Comment Guidelines
- All comments and documentation must be in English
- Use `// MARK:` for code organization
- Document complex algorithms and business logic
- Include TODO/FIXME comments with context

### Testing
- Write unit tests for new functionality using Swift Testing
- Include UI tests for critical user flows
- Test on both iOS and watchOS when applicable
- Verify CloudKit sync functionality

## 🐛 Reporting Issues

### Bug Reports
Please include:
- **Description**: Clear description of the issue
- **Steps to reproduce**: Detailed steps to trigger the bug
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Environment**: iOS/watchOS version, device model
- **Screenshots**: If applicable

### Feature Requests
Please include:
- **Problem**: What problem does this solve?
- **Solution**: Describe your proposed solution
- **Alternatives**: Any alternative solutions considered
- **Use cases**: Who would benefit from this feature?

## 🔄 Pull Request Process

### Before Submitting
1. **Create an issue** first to discuss the change
2. **Fork the repository** and create a feature branch
3. **Write tests** for new functionality
4. **Update documentation** if needed
5. **Test thoroughly** on devices when possible

### Pull Request Checklist
- [ ] Code follows project style guidelines
- [ ] All comments and documentation are in English
- [ ] Tests pass (unit and UI tests)
- [ ] New functionality includes appropriate tests
- [ ] Documentation has been updated
- [ ] Localization keys added for new strings
- [ ] No merge conflicts with main branch

### Pull Request Template
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
- [ ] UI tests pass
- [ ] Manual testing completed
- [ ] Tested on device

## Screenshots
Include screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated
```

## 🌍 Localization

### Adding New Languages
1. Create new `.lproj` folder in `Resources/`
2. Copy `en.lproj/Localizable.strings` as template
3. Translate all strings maintaining key format
4. Test with new language setting
5. Update README with supported languages

### Translation Guidelines
- Maintain context and meaning
- Keep string length reasonable for UI
- Use appropriate formality level
- Test with longer translations
- Consider cultural differences

## 🎨 Design System

### Using DS Components
- Use existing `DS` components when possible
- Follow established color and typography patterns
- Maintain consistency across iOS and watchOS
- Consider accessibility requirements

### Adding New Components
- Follow existing component patterns
- Include documentation and examples
- Support both light and dark modes
- Test with Dynamic Type sizes
- Consider watchOS constraints

## 🧪 Testing Strategy

### Unit Tests
- Test business logic and data models
- Mock external dependencies
- Use Swift Testing framework
- Aim for meaningful test coverage

### UI Tests
- Test critical user flows
- Verify accessibility features
- Test on different screen sizes
- Include error scenarios

### Manual Testing
- Test on physical devices when possible
- Verify CloudKit sync functionality
- Test widget and Siri integration
- Check performance and battery usage

## 📚 Documentation

### Code Documentation
- Document public APIs
- Include usage examples
- Explain complex algorithms
- Keep documentation up to date

### User Documentation
- Update README for new features
- Include screenshots and examples
- Maintain accuracy with code changes
- Consider user skill levels

## 🏷️ Git Conventions

### Branch Naming
- `feature/description-of-feature`
- `bugfix/description-of-bug`
- `docs/description-of-docs-change`
- `refactor/description-of-refactor`

### Commit Messages
Follow conventional commits format:
```
type(scope): description

- feat: new feature
- fix: bug fix
- docs: documentation changes
- style: formatting changes
- refactor: code refactoring
- test: adding tests
- chore: maintenance tasks
```

Examples:
```
feat(analytics): add weekly trend analysis
fix(widget): resolve timeline update issue
docs(readme): update installation instructions
```

## 🤔 Questions and Support

### Getting Help
- **GitHub Discussions**: For general questions and ideas
- **GitHub Issues**: For bug reports and feature requests
- **Email**: roberdan@fightthestroke.org for sensitive topics

### Community Guidelines
- Be respectful and inclusive
- Help others learn and grow
- Focus on constructive feedback
- Follow the Code of Conduct

## 📄 Legal

### License
By contributing, you agree that your contributions will be licensed under the MIT License.

### Copyright
- Retain original copyright notices
- Add your name to contributor lists if desired
- Don't include copyrighted material without permission

---

**Thank you for contributing to Mirror Smoker!** 🚭

Your contributions help create a better tool for people working to reduce their smoking habits. Every bug fix, feature, and improvement makes a difference in someone's health journey.

