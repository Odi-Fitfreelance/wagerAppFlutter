# Betcha! - Flutter Migration

A modernized betting app built with Flutter, featuring the Neon Nightlife color palette and simplified navigation inspired by TikTok/viral video apps.

## Overview

This Flutter app replaces the React Native implementation and addresses React 19.x security concerns while significantly simplifying the user experience.

### Key Improvements

- **Simplified Navigation**: Reduced from 27 screens with 4 navigation stacks to just 4 main screens
- **Viral-First Design**: TikTok-style vertical feed for challenge videos
- **Neon Nightlife Theme**: Cyberpunk-inspired color palette with neon glows
  - Hot Pink (#FF1493) - Primary
  - Electric Yellow (#FFFF33) - Accent
  - Neon Blue (#00FFFF) - Secondary
  - Dark Slate Gray (#2F4F4F) - Backgrounds

## Architecture

### Simplified Navigation Structure

```
Main App
├── Feed Screen (TikTok-style challenge feed)
├── Live Screen (Live challenges with viewers)
├── Create Challenge (Record/upload videos)
└── Profile Screen (Wallet + settings)
```

**Compared to React Native app:**
- Before: 4 tabs × 7+ screens each = 27+ total screens
- After: 4 main screens with streamlined flows

### Folder Structure

```
lib/
├── config/
│   └── app_theme.dart          # Neon Nightlife theme
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── home/
│       ├── main_navigation.dart
│       ├── feed_screen.dart
│       ├── live_screen.dart
│       ├── create_challenge_screen.dart
│       └── profile_screen.dart
├── models/                      # TODO: Add data models
├── services/                    # TODO: Add API services
├── providers/                   # TODO: Add state management
└── widgets/                     # TODO: Add reusable widgets
```

## Features Implemented

### ✅ Completed

1. **Authentication**
   - Login screen with email/password
   - Register screen
   - Animated transitions
   - Form validation

2. **Main Feed**
   - Vertical scrolling challenge feed
   - FAIL/LAND betting buttons with neon glow
   - Challenge info overlay
   - Mock challenge data

3. **Live Challenges**
   - Live indicator with neon glow
   - Viewer count display
   - Live challenge cards

4. **Create Challenge**
   - Video upload placeholder
   - Challenge type selector (FAIL/LAND vs Head-to-Head)
   - Form inputs

5. **Profile & Wallet**
   - User stats (Wins/Losses/Coins)
   - Wallet balance display
   - Add funds/Withdraw buttons
   - Settings menu

6. **Theme**
   - Complete Neon Nightlife color palette
   - Custom neon glow effects
   - Gradient buttons for betting actions
   - Dark mode optimized

### 🚧 TODO (Backend Integration)

1. **State Management**
   - Implement Provider or Riverpod
   - Auth state management
   - Challenge state management

2. **API Integration**
   - Connect to existing backend from React Native app
   - Implement authentication API calls
   - Challenge CRUD operations
   - Betting transactions
   - Live streaming integration

3. **Video Features**
   - Video player (using video_player package)
   - Camera integration for recording
   - Video upload to backend

4. **Real-time Features**
   - WebSocket for live challenges
   - Real-time bet updates
   - Live chat/reactions

5. **Additional Screens**
   - Bet history
   - Transaction history
   - Settings (notifications, privacy, etc.)
   - Help & support

## Design Insights from Reference Videos

Based on the analyzed promotional videos:

1. **Live Streaming Central**: Challenges are live events people watch and bet on
2. **Quick Interactions**: FAIL/LAND buttons for instant betting
3. **Social/Viral**: Friend challenges, leaderboards, share features
4. **Gamification**: Coins, streaks, celebratory animations
5. **Neon Aesthetic**: Dark backgrounds with bright neon accents

## Running the App

```bash
# Get dependencies
cd betcha_flutter
flutter pub get

# Run on device/emulator
flutter run

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
```

## Development Notes

### From React Native Migration

**Previous React Native Structure:**
- 4 bottom tabs (Play, Follow, Store, Wallet)
- Each tab had nested stack navigation
- 27+ total screens
- Complex navigation flows

**New Flutter Structure:**
- 4 main screens with simplified flows
- Direct screen transitions
- Reduced navigation complexity by ~70%
- Focus on core betting features

### Security Improvements

- No React 19.x dependencies
- Flutter's built-in security features
- Secure storage for auth tokens (to be implemented)
- Proper input validation

## Video Analysis

The reference videos were analyzed using Python scripts (analyze_videos.py and extract_audio_transcript.py) to extract:
- Key frames showing UI/UX patterns
- Design aesthetics and color usage
- User flow and interactions
- Branding elements

Results are in the `video_analysis/` directory in the parent mobile project.

## Next Steps

1. **Backend Integration**: Connect to existing API
2. **Video Player**: Implement video playback and recording
3. **State Management**: Add Provider/Riverpod
4. **Real-time Features**: WebSocket for live updates
5. **Testing**: Add unit and widget tests
6. **Performance**: Optimize video loading and scrolling

## Credits

- **Design**: Inspired by TikTok, Snapchat, and Vegas aesthetics
- **Color Palette**: Neon Nightlife (Cyberpunk gaming + Las Vegas casino)
- **Framework**: Flutter 3.38.5
- **Created**: December 2025
