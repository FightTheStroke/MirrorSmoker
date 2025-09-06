# Contributing to MirrorSmoker 🤝

Thank you for your interest in contributing to MirrorSmoker! This document provides guidelines and information for contributors to this production-ready iOS smoking cessation app.

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
- **Xcode 15.0 or later**
- **iOS 17.0+ / watchOS 10.0+** development experience
- **SwiftUI and SwiftData** proficiency
- **CloudKit** understanding for sync features
- **Fastlane** knowledge for deployment (optional)
- **Ruby/Bundler** for automation tools

### Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/yourusername/mirror-smoker.git
   cd mirror-smoker
   ```

2. **Install dependencies**
   ```bash
   # Install Fastlane dependencies
   bundle install
   ```

3. **Open in Xcode**
   ```bash
   open MirrorSmokerStopper.xcodeproj
   ```

4. **Configure development environment**
   - Select your development team in project settings
   - Update bundle identifiers for testing:
     - Main app: `com.yourteam.mirrorsmoker`
     - Widget: `com.yourteam.mirrorsmoker.widget`  
     - Watch app: `com.yourteam.mirrorsmoker.watchapp`
   - Enable required capabilities (iCloud, App Groups, HealthKit)

5. **Build and test**
   ```bash
   # Build the project
   ⌘+B in Xcode
   
   # Run comprehensive tests
   bundle exec fastlane test
   # or ⌘+U in Xcode
   
   # Test on physical device (recommended)
   ```

## 📋 Development Guidelines

### Code Style
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftUI best practices and modern Swift features
- Prefer Swift Concurrency (async/await) over completion handlers
- Keep files under 250 lines when possible
- Use meaningful variable and function names

### Architecture Patterns
- **MVVM**: Use SwiftUI patterns with `@State`, `@Observable`, `@Query`
- **SwiftData**: Leverage `@Model` for persistence, `@Query` for data fetching
- **Design System**: Utilize existing `DS` components for consistency
- **Privacy-First**: No third-party analytics, local-only AI processing
- **Localization**: All strings must support 5 languages (EN, IT, ES, FR, DE)
- **Sync Architecture**: CloudKit + App Groups for seamless device sync

### Comment Guidelines
- All comments and documentation must be in English
- Use `// MARK:` for code organization
- Document complex algorithms and business logic
- Include TODO/FIXME comments with context

### Testing Requirements
- **Unit Tests**: Use Swift Testing framework for business logic
- **UI Tests**: Cover critical user flows and accessibility
- **Integration Tests**: Verify CloudKit sync, widget updates, watch connectivity
- **Localization Tests**: Test in all 5 supported languages
- **Device Testing**: Test on physical iPhone and Apple Watch
- **Performance Tests**: Monitor memory usage and battery impact

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
- [ ] Code follows Swift API Design Guidelines
- [ ] All comments and documentation are in English
- [ ] Comprehensive tests pass (unit, UI, integration)
- [ ] New functionality includes appropriate test coverage
- [ ] Documentation updated (README, ARCHITECTURE.md if needed)
- [ ] Localization complete for all 5 languages
- [ ] Widget and Watch app compatibility verified
- [ ] CloudKit sync functionality tested
- [ ] AI Coach integration considered (if applicable)
- [ ] Privacy implications reviewed
- [ ] Performance impact assessed
- [ ] No merge conflicts with development branch

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

### Current Languages (Production Ready)
- **English (en)** - Base language
- **Italian (it)** - Complete localization
- **Spanish (es)** - Full translation
- **French (fr)** - Native localization
- **German (de)** - Complete German support

### Adding New Languages
1. **App Localization**
   - Create new `.lproj` folder in `Resources/`
   - Copy `en.lproj/Localizable.strings` as template
   - Translate all strings maintaining key format
   - Update Info.plist for new language support

2. **App Store Localization**
   - Create new language folder in `fastlane/metadata/`
   - Copy `en-US/` metadata structure
   - Translate app description, keywords, release notes
   - Add localized screenshots

3. **Testing**
   - Test with new language device setting
   - Verify widget text updates correctly
   - Test Siri integration in new language
   - Check text truncation and layout

4. **Documentation**
   - Update README with new supported language
   - Add language to DEPLOYMENT.md
   - Update App Store listing information

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
- **Data Models**: SwiftData persistence, relationships, migrations
- **Business Logic**: AI Coach algorithms, pattern recognition, statistics
- **Managers**: TagManager, AppGroupManager, CloudKit sync logic
- **Utilities**: Date helpers, design system components
- **Coverage Target**: 80%+ for critical business logic

### Integration Tests
- **CloudKit Sync**: Multi-device data synchronization
- **Widget Integration**: App Groups data sharing and timeline updates
- **Watch Connectivity**: iPhone-Watch real-time sync
- **HealthKit Integration**: Data reading and privacy compliance
- **Siri Integration**: App Intents and voice command handling

### UI Tests
- **Critical User Flows**: Cigarette logging, tag management, statistics
- **Accessibility**: VoiceOver navigation, Dynamic Type support
- **Multi-Platform**: iPhone, Apple Watch interfaces
- **Localization**: UI layout with different text lengths
- **Error States**: Network failures, permission denials

### Manual Testing (Required)
- **Physical Devices**: iPhone and Apple Watch testing
- **Real iCloud Account**: Multi-device sync verification
- **All 5 Languages**: Complete localization testing
- **Performance**: Battery usage, memory consumption
- **Privacy**: Data isolation, no third-party connections

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

**Thank you for contributing to MirrorSmoker!** 🚭

Your contributions help maintain and enhance this production-ready, privacy-first smoking cessation platform. With 147 Swift files implementing comprehensive AI coaching, premium features, and full internationalization, every contribution makes a real difference in users' health journeys. Together, we're evolving a complete smoking cessation ecosystem that respects user privacy while providing powerful, AI-powered insights and personalized support.

