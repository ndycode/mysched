# MySched Design System

Version 1.0 | Last Updated: December 2024

---

## Table of Contents

1. [Design System Overview](#1-design-system-overview)
2. [Brand Foundations](#2-brand-foundations)
3. [Layout and Spacing System](#3-layout-and-spacing-system)
4. [Component System](#4-component-system)
5. [Motion and Interaction System](#5-motion-and-interaction-system)
6. [Accessibility Standards](#6-accessibility-standards)
7. [Platform-Specific Guidelines](#7-platform-specific-guidelines)
8. [Data and State Design](#8-data-and-state-design)
9. [Iconography and Imagery](#9-iconography-and-imagery)
10. [Governance and Evolution](#10-governance-and-evolution)

---

## 1. Design System Overview

### 1.1 Purpose

The MySched Design System exists to provide a unified, scalable foundation for building consistent user experiences across mobile (Flutter) and web (Next.js) platforms. This system serves as the single source of truth for all visual, interactive, and accessibility standards used throughout the MySched product ecosystem.

#### Problems This System Solves

**Consistency**: Without a formalized design system, visual inconsistencies accumulate across screens, features, and platforms. MySched's token-based architecture ensures that colors, spacing, typography, and motion behaviors remain predictable regardless of where they appear.

**Accessibility**: Academic products serve diverse student populations with varying abilities. This system embeds accessibility requirements directly into component specifications rather than treating them as an afterthought.

**Scalability**: As MySched grows to support more features and potentially more platforms, the design system provides a stable foundation that can evolve without requiring wholesale redesigns.

**Developer Efficiency**: Clear specifications reduce decision fatigue for engineers. When a developer needs to implement a card component, they reference a single specification rather than inferring patterns from existing code.

**Student-Focused Design**: Academic scheduling is inherently stressful. This system prioritizes calm, clear interfaces that reduce cognitive load and help students focus on their education rather than wrestling with confusing software.

### 1.2 Design Principles

The following principles guide all design decisions within MySched:

#### Clarity Over Decoration

Every visual element must serve a functional purpose. Decorative flourishes that do not aid comprehension or navigation are avoided. Interface elements should communicate their purpose immediately without requiring explanation.

#### Calm, Academic Confidence

MySched serves students managing complex academic schedules. The visual language conveys reliability and professionalism without feeling sterile. Colors remain muted, typography prioritizes legibility, and layouts provide adequate breathing room.

#### Motion With Purpose

Animations exist to provide feedback, guide attention, or communicate state changes. Motion is never purely decorative. All transitions are brief enough to feel responsive but long enough to be perceived. Motion respects user preferences for reduced motion.

#### Accessibility By Default

Accessibility compliance is not optional. All components meet WCAG 2.1 AA standards as a baseline requirement. Color contrast, touch target sizing, screen reader support, and keyboard navigation are built into initial specifications rather than retrofitted.

#### Offline-First UX Resilience

Students frequently operate in environments with unreliable internet connectivity. The interface must clearly communicate connection status and remain functional during offline periods. Data synchronization feedback must be transparent and non-disruptive.

#### Predictable Interaction Patterns

Users should never wonder how to interact with an element. Buttons look like buttons. Tappable areas communicate their interactivity. Gestures follow platform conventions. Consistency builds trust and reduces learning curves.

#### Respectful of Time

Students have limited attention spans and competing demands. Interfaces load quickly, information hierarchies are clear, and common tasks require minimal steps. The system never wastes the user's time.

---

## 2. Brand Foundations

### 2.1 Brand Voice and Tone

#### Primary Tone: Calm, Clear, Trustworthy

MySched communicates with the measured confidence of a knowledgeable academic advisor. Language is direct without being curt. Instructions are specific. Feedback is constructive. The app speaks to students as capable adults managing their own education.

**Characteristics:**
- Uses plain language over academic jargon
- Provides complete information without over-explaining
- Maintains a neutral emotional register
- Prioritizes action-oriented messaging

#### Secondary Tone: Supportive, Academic-Friendly

When students encounter difficulties or complete tasks successfully, the tone shifts slightly warmer while remaining professional. Encouragement is offered without condescension. Errors are explained without blame.

**Characteristics:**
- Acknowledges user effort and progress
- Offers helpful suggestions rather than demands
- Uses inclusive language
- Celebrates achievements appropriately

#### What MySched Never Sounds Like

- **Patronizing**: Avoiding phrases like "Good job!" for routine tasks
- **Corporate**: No marketing speak or promotional language within the product
- **Vague**: Never "Something went wrong" without actionable context
- **Alarmist**: Error states communicate severity without inducing panic
- **Overly Casual**: No slang, emoji usage, or attempts at humor

#### Copy Guidelines

| Context | Do | Do Not |
|---------|-----|--------|
| Empty States | "No classes scheduled for today" | "Nothing here yet!" |
| Success Confirmation | "Schedule saved" | "Awesome! Your schedule is saved!" |
| Error Messages | "Unable to save. Check your connection and try again." | "Oops! Something went wrong." |
| Loading States | "Loading schedule..." | "Hang tight..." |
| Destructive Actions | "Delete this reminder? This cannot be undone." | "Are you sure? This is permanent!" |

#### Error Message Tone Guidelines

Error messages follow a consistent structure:

1. **State what happened** (briefly)
2. **Explain why** (if known and helpful)
3. **Provide next steps** (actionable)

**Examples:**

```
Unable to sync schedule
Your device is offline. Changes will sync when connection is restored.

Failed to load classes
The server is temporarily unavailable. Pull down to retry.

Session expired
Please sign in again to continue.
```

---

### 2.2 Color System

MySched uses a comprehensive color palette with light, dark, and void (AMOLED-optimized) theme variants. All colors are defined as design tokens and applied through the theme system.

#### 2.2.1 Core Brand Color

| Token | Hex Value | Purpose |
|-------|-----------|---------|
| `primary` | `#0066FF` | Primary brand color, interactive elements, CTAs |
| `brand` | `#1A5DFF` | Brand accent for splash screens and loading states |

The primary blue conveys trust, stability, and professionalism appropriate for an academic context. It provides sufficient contrast against both light and dark backgrounds.

#### 2.2.2 Semantic Colors

**Success / Positive**

| Theme | Hex Value | Usage |
|-------|-----------|-------|
| Light | `#1FB98F` | Success states, completed tasks, positive feedback |
| Dark | `#44E5BC` | Adjusted for dark background visibility |

**Warning**

| Theme | Hex Value | Usage |
|-------|-----------|-------|
| All | `#FFAE04` | Warnings, pending states, attention required |

**Error / Danger**

| Theme | Hex Value | Usage |
|-------|-----------|-------|
| All | `#E54B4F` | Errors, destructive actions, critical alerts |

**Info**

| Theme | Hex Value | Usage |
|-------|-----------|-------|
| All | `#2D61EF` | Informational messages, help content |

#### 2.2.3 Neutral Grayscale

**Light Mode Palette**

| Token | Hex Value | Purpose |
|-------|-----------|---------|
| `surface` | `#FFFFFF` | Primary surface color |
| `background` | `#FCFCFC` | App background |
| `surfaceVariant` | `#F7F7F7` | Elevated surfaces, cards |
| `outline` | `#EBEBEB` | Borders, dividers |
| `onSurface` | `#000000` | Primary text |
| `onSurfaceVariant` | `#707070` | Secondary text |
| `muted` | `#4B556D` | Muted text, captions |
| `mutedSecondary` | `#7F8AA7` | Tertiary text |

**Dark Mode Palette**

| Token | Hex Value | Purpose |
|-------|-----------|---------|
| `surface` | `#1A1A1A` | Primary surface color |
| `background` | `#000000` | App background |
| `surfaceVariant` | `#262626` | Elevated surfaces, cards |
| `outline` | `#333333` | Borders, dividers |
| `onSurface` | `#FFFFFF` | Primary text |
| `onSurfaceVariant` | `#A6A6A6` | Secondary text |
| `muted` | `#8B95AD` | Muted text, captions |
| `mutedSecondary` | `#9AA4BC` | Tertiary text |

**Void Mode Palette (AMOLED Optimized)**

| Token | Hex Value | Purpose |
|-------|-----------|---------|
| `surface` | `#050505` | Near-black primary surface |
| `background` | `#000000` | True black background |
| `surfaceVariant` | `#141414` | Subtle elevation difference |
| `outline` | `#262626` | Borders, dividers |

Void mode provides maximum battery savings on OLED displays while maintaining visual hierarchy through subtle surface elevation.

#### 2.2.4 Overlay and Container Colors

| Token | Hex Value (Light) | Hex Value (Dark) | Purpose |
|-------|-------------------|------------------|---------|
| `overlay` | `#0066FF` @ 8% | `#0066FF` @ 20% | Tinted overlays |
| `primaryContainer` | `#DDE7FF` | `#002255` | Primary color containers |
| `onPrimaryContainer` | `#001A4D` | `#DDE7FF` | Text on primary containers |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | Text on primary surfaces |

#### 2.2.5 Avatar Gradient Colors

| Token | Hex Value | Purpose |
|-------|-----------|---------|
| `avatarGradientStart` | `#95BAFF` | Avatar placeholder gradient start |
| `avatarGradientEnd` | `#6FB7FF` | Avatar placeholder gradient end |

#### 2.2.6 Accent Color Presets

Users can customize the primary accent color. Available presets:

| Name | Hex Value |
|------|-----------|
| Default Blue | `#0066FF` |
| Coral Red | `#FF6B6B` |
| Sunset Orange | `#FF8F59` |
| Golden Yellow | `#FFC928` |
| Emerald Green | `#36D399` |
| Violet Purple | `#9B5DE5` |
| Rose Pink | `#FF7EB3` |

#### 2.2.7 Color Accessibility Requirements

All color combinations must meet WCAG 2.1 AA contrast requirements:

- **Normal text (< 18pt)**: Minimum 4.5:1 contrast ratio
- **Large text (>= 18pt or 14pt bold)**: Minimum 3:1 contrast ratio
- **UI components and graphics**: Minimum 3:1 contrast ratio

Semantic colors have been tested against all surface colors in both light and dark modes to ensure compliance.

**Color Usage Rules:**
- Never rely on color alone to convey information
- Pair color indicators with icons or text labels
- Test designs with color blindness simulators
- Maintain consistent color meanings across the application

---

### 2.3 Typography

#### 2.3.1 Primary Font Family

**SF Pro Rounded** is the primary typeface for MySched. This font provides excellent legibility at small sizes while maintaining a friendly, approachable character appropriate for student-focused software.

**Fallback Stack:**
```
SF Pro Rounded, SF Pro Display, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif
```

#### 2.3.2 Type Scale

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| `brand` | 42px | 700 (Bold) | 1.1 | Default | Splash screens, major branding |
| `display` | 32px | 700 (Bold) | 1.12 | Default | Hero sections, primary headers |
| `headline` | 26px | 600 (SemiBold) | 1.2 | Default | Section headers, screen titles |
| `title` | 20px | 600 (SemiBold) | 1.28 | Default | Card titles, subsection headers |
| `subtitle` | 16px | 500 (Medium) | 1.36 | Default | Subtitles, emphasized body text |
| `body` | 16px | 400 (Regular) | 1.5 | Default | Primary body text |
| `bodySecondary` | 14px | 400 (Regular) | 1.45 | Default | Secondary body text |
| `label` | 14px | 600 (SemiBold) | 1.36 | 0.3px | Button labels, form labels |
| `caption` | 12px | 500 (Medium) | 1.35 | 0.1px | Captions, timestamps, metadata |
| `micro` | 10px | 500 (Medium) | 1.3 | 0.2px | Badges, small labels |

#### 2.3.3 Font Weight Tokens

| Token | Weight | Usage |
|-------|--------|-------|
| `regular` | 400 | Body text |
| `medium` | 500 | Slight emphasis, captions |
| `semiBold` | 600 | Labels, subtitles |
| `bold` | 700 | Headlines, strong emphasis |
| `extraBold` | 800 | Brand/display text |

#### 2.3.4 Line Height Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `single` | 1.0 | Single-line elements, icons |
| `tight` | 1.1 | Display text |
| `display` | 1.12 | Hero text |
| `headline` | 1.2 | Headlines |
| `title` | 1.28 | Titles |
| `compact` | 1.3 | UI labels |
| `caption` | 1.35 | Captions |
| `subtitle` | 1.36 | Subtitles |
| `relaxed` | 1.4 | Relaxed body |
| `bodySecondary` | 1.45 | Secondary body |
| `body` | 1.5 | Primary body |

#### 2.3.5 Letter Spacing Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `tight` | -0.5px | Large headings |
| `snug` | -0.3px | Titles |
| `compact` | -0.2px | Slightly tight |
| `normal` | 0px | Default |
| `relaxed` | 0.1px | Slightly wide |
| `wide` | 0.2px | Captions |
| `wider` | 0.3px | Labels |
| `widest` | 0.4px | All-caps text |
| `sectionHeader` | 1.2px | Section headers |
| `otpCode` | 6.0px | Verification codes |

#### 2.3.6 Typography Usage Guidelines

**Maximum Readable Line Length:**
- Body text should not exceed 600px width (approximately 70-80 characters)
- Headlines can extend to full content width

**Dynamic Text Scaling:**
- All text styles support responsive scaling via `ResponsiveTypography` extension
- Scale factor is calculated relative to a 412dp reference width (Pixel 8 Pro)
- Compact devices (< 380dp) scale down proportionally
- Text must remain legible at 200% system font size

**Platform Differences:**
- Mobile (Flutter): Uses native SF Pro Rounded font
- Web (Next.js): Falls back to system fonts with similar characteristics

---

## 3. Layout and Spacing System

### 3.1 Spacing Scale

MySched uses a 4px base grid with a comprehensive spacing scale. All spacing values are multiples of the base unit.

| Token | Value | Usage |
|-------|-------|-------|
| `none` | 0px | No spacing |
| `microHalf` | 1px | Pixel-perfect adjustments |
| `micro` | 2px | Fine-tuning, borders |
| `xs` / `microLg` | 4px | Compact gaps |
| `xsHalf` | 5px | Tight chip padding |
| `xsPlus` | 6px | Extra-small plus |
| `sm` | 8px | Small gaps, icon padding |
| `smMd` | 10px | Small-medium |
| `md` | 12px | Standard gaps |
| `mdLg` | 14px | Medium-large |
| `lg` | 16px | Section spacing (base unit) |
| `lgPlus` | 18px | Card padding adjustment |
| `xl` | 20px | Page margins |
| `xlHalf` | 22px | XL half-step |
| `xxl` | 24px | Major section breaks |
| `xxlPlus` | 28px | XXL plus |
| `xxxl` | 32px | Hero spacing |
| `quad` | 40px | Large hero sections |
| `emptyStateSize` | 64px | Empty state containers |

### 3.2 Layout Constraints

| Token | Value | Purpose |
|-------|-------|---------|
| `bottomNavSafePadding` | 120px | Bottom padding for nav bar + FAB |
| `sheetMaxWidth` | 520px | Maximum modal sheet width |
| `sheetMinHeight` | 360px | Minimum modal sheet height |
| `sheetMaxHeightRatio` | 78% | Maximum sheet height (screen %) |
| `dialogMaxWidth` | 400px | Maximum dialog width |
| `dialogWidthSmall` | 340px | Small confirmation dialogs |
| `dialogMaxHeightRatio` | 60% | Maximum dialog height (screen %) |
| `contentMaxWidth` | 600px | Main content area max width |
| `contentMaxWidthMedium` | 640px | Form content max width |
| `contentMaxWidthWide` | 720px | Tablet/desktop content |
| `contentMaxWidthExtraWide` | 840px | Large display content |
| `pagePaddingHorizontal` | 20px | Default horizontal page padding |
| `pagePaddingVertical` | 24px | Default vertical page padding |
| `listCacheExtent` | 800px | List performance optimization |

### 3.3 Responsive Breakpoints

| Token | Value | Description |
|-------|-------|-------------|
| `compactThreshold` | 380px | Below this: compact layout |
| `referenceWidth` | 412px | Baseline for scaling (1.0) |
| `wideLayoutBreakpoint` | 520px | Wide layout trigger |
| `wideThreshold` | 600px | Tablet/wide screen |

### 3.4 Border Radius Scale

| Token | Value | Usage |
|-------|-------|-------|
| `micro` | 2px | Handles, subtle rounding |
| `microPlus` | 4px | Micro-plus |
| `xs` | 6px | Checkboxes, small elements |
| `sm` | 8px | Small components |
| `chip` | 10px | Chips, tags |
| `md` | 12px | Cards, containers |
| `popup` | 14px | Popups, list tiles |
| `lg` | 16px | Large cards |
| `sheet` | 20px | Sheets, dialogs |
| `xl` | 24px | Extra large |
| `button` | 26px | Buttons |
| `xxl` | 28px | XXL |
| `xxxl` | 32px | XXXL |
| `pill` | 999px | Fully rounded pills |

### 3.5 Screen Margins and Safe Areas

**Mobile (Flutter):**
- Horizontal margins: 20px (`xl`)
- Top safe area: System status bar + 32px (`xxxl`)
- Bottom safe area: `bottomNavSafePadding` (120px) when navigation is visible

**Web (Next.js):**
- Content centered with `contentMaxWidth` constraint
- Minimum horizontal padding: 24px on compact viewports
- Maximum content width: 840px on large displays

### 3.6 Vertical Rhythm

All vertical spacing between elements should follow the spacing scale. Consistent vertical rhythm creates visual harmony and improves scannability.

**Section Spacing:**
- Between major sections: `xxl` (24px) or `xxxl` (32px)
- Between related elements: `md` (12px) or `lg` (16px)
- Between tightly related elements: `sm` (8px) or `xs` (4px)

---

## 4. Component System

This section documents core UI components with their variants, states, behaviors, and specifications.

### 4.1 Buttons

#### 4.1.1 Primary Button (FilledButton)

**Purpose:** Primary calls-to-action, form submissions, key actions.

**Specifications:**
- Height: 52px (`buttonLg`)
- Padding: 20px horizontal, 12px vertical
- Border Radius: 26px (`button`)
- Background: `primary` color
- Text: `onPrimary` color, `label` typography

**States:**

| State | Visual Change |
|-------|---------------|
| Default | Standard appearance |
| Pressed | Scale to 96%, brief opacity reduction to 85% |
| Disabled | 65% opacity, no interaction |
| Loading | Spinner replaces text, button remains tappable area |

**Accessibility:**
- Minimum touch target: 48x48px
- Focus indicator: 2px outline offset by 2px
- Screen reader: Announce button label and state

**Do:**
- Use for single primary action per screen
- Keep labels concise (1-3 words)
- Provide loading feedback for async actions

**Do Not:**
- Use multiple primary buttons in close proximity
- Disable without explanation
- Use for navigation (use links instead)

#### 4.1.2 Secondary Button (OutlinedButton)

**Purpose:** Secondary actions, alternative options.

**Specifications:**
- Height: 52px (`buttonLg`)
- Border: 1px solid `primary` @ 40% opacity
- Background: Transparent
- Text: `primary` color

**States:** Same scale/opacity behaviors as Primary Button.

#### 4.1.3 Tertiary Button (TextButton)

**Purpose:** Low-emphasis actions, cancellation, navigation links.

**Specifications:**
- Height: 52px
- Background: Transparent
- Padding: 16px horizontal, 8px vertical
- Text: `primary` color

**Do:**
- Use for "Cancel" or "Skip" actions
- Use for inline links within content

**Do Not:**
- Use for primary actions
- Stack multiple tertiary buttons

#### 4.1.4 Destructive Button

**Purpose:** Irreversible actions (delete, remove, sign out).

**Specifications:**
- Same structure as Primary Button
- Background: `danger` color
- Requires confirmation dialog for critical actions

---

### 4.2 Cards

**Purpose:** Group related content, create visual hierarchy, provide tappable surfaces.

#### 4.2.1 Standard Card (CardX)

**Specifications:**
- Background: Theme-dependent (see `card_styles.dart`)
  - Light: Surface with subtle primary tint
  - Dark: `surfaceContainerHigh` @ 78% opacity
- Border: 0.5-1px, color varies by theme
- Border Radius: 16px (`lg`)
- Elevation: 0 (flat design)
- Padding: Configurable, default 24px (`xxl`)

**Interactive Cards:**
- Hover scale: 1.015 (`scaleHoverMicro`)
- Press scale: 0.98 (`scalePressCard`)
- Animation duration: 100-150ms

#### 4.2.2 Surface Card

**Purpose:** Subtle content grouping without strong visual separation.

**Specifications:**
- Background: `surfaceVariant` @ reduced opacity
- Border: None or very subtle
- Used for nested content within screens

#### 4.2.3 Hero Gradient Card

**Purpose:** Dashboard hero sections, promotional content.

**Specifications:**
- Background: Gradient from `primary` to `brand`
- Text: `onPrimary` color
- Full-width or constrained based on context

---

### 4.3 Inputs and Text Fields

**Purpose:** User data entry for forms.

**Specifications:**
- Height: Determined by content + padding
- Padding: 20px horizontal, 16px vertical
- Border Radius: 16px (`lg`)
- Background: `surfaceContainerHigh` @ 50% opacity
- Border: 1px solid `outline` @ 20% opacity

**States:**

| State | Border | Background |
|-------|--------|------------|
| Default | `outline` @ 20% | `surfaceContainerHigh` @ 50% |
| Focused | `primary` 1.5px | Same |
| Error | `error` @ 50% | Same |
| Disabled | Same as default | Reduced opacity |

**Label Styling:**
- Position: Floating or fixed based on context
- Color: `onSurfaceVariant`
- Style: `bodySecondary` typography

**Error Styling:**
- Error message: `caption` typography, `error` color, `medium` weight
- Border: `error` color

**Accessibility:**
- Labels must be associated with inputs
- Error messages announced to screen readers
- Touch target includes entire input area

---

### 4.4 Modals and Dialogs

#### 4.4.1 Bottom Sheet

**Purpose:** Contextual actions, secondary forms, detail views.

**Specifications:**
- Background: `surface`
- Border Radius: 20px (`sheet`) top corners only
- Max Height: 78% of screen
- Handle: 40px wide, 4px tall, centered, `outline` color

**Animation:**
- Enter: 350ms ease-out, slide from bottom
- Exit: 250ms ease-in, slide down
- Barrier: `#000000` @ 45% opacity

#### 4.4.2 Center Dialog

**Purpose:** Confirmations, alerts, critical decisions.

**Specifications:**
- Background: `surface`
- Border Radius: 20px (`sheet`)
- Max Width: 400px
- Min Width: 280px
- Padding: 24px

**Animation:**
- Enter: 300ms with overshoot, scale from 0.9
- Exit: 200ms ease-in, scale down

**Content Structure:**
1. Title (optional icon)
2. Message body
3. Action buttons (right-aligned)

---

### 4.5 Toasts and Snackbars

**Purpose:** Non-blocking feedback, confirmations, brief alerts.

**Specifications:**
- Position: Bottom of screen, above navigation
- Background: `surfaceContainerHigh`
- Border: 1px solid `outline` @ 12% opacity
- Border Radius: 20px (`sheet`)
- Padding: 24px horizontal, 12px vertical
- Max Width: Constrained to content area
- Duration: 4 seconds default, configurable

**Content:**
- Icon (optional): Semantic color based on message type
- Text: `body` typography, `onSurface` color, `semiBold` weight
- Action: Text button (optional)

**Animation:**
- Enter: Slide up + fade in
- Exit: Fade out

**Accessibility:**
- Role: alert or status based on urgency
- Announced by screen readers
- Dismissible via swipe or timeout

---

### 4.6 Navigation

#### 4.6.1 Bottom Navigation Bar

**Purpose:** Primary app navigation between main sections.

**Specifications:**
- Height: 64-68px depending on safe areas
- Background: Glass effect with surface blur
- Items: 3-5 destinations
- Active indicator: Pill shape with brand color

**Item Specifications:**
- Width: 72px minimum
- Icon size: 24px (`lg`)
- Label: `caption` typography
- Active: `primary` color
- Inactive: `onSurfaceVariant` color

**Central FAB:**
- Size: 56px
- Offset: -22px from nav bar top
- Contains primary action icon

#### 4.6.2 App Bar

**Purpose:** Screen identity, navigation controls, contextual actions.

**Specifications:**
- Background: Transparent (content scrolls behind)
- Height: System status bar + content
- Title: `title` typography, `onSurface` color
- Back button: Standard platform pattern

---

### 4.7 Empty States

**Purpose:** Guide users when content is unavailable.

**Specifications:**
- Container: Centered, full-width
- Icon container: 56px (compact) or 88px (large)
- Icon: 28px (compact) or 36px (large)
- Icon color: `onSurfaceVariant` @ muted opacity
- Title: `subtitle` typography, `onSurface` color
- Message: `bodySecondary` typography, `muted` color
- Action: Optional primary or secondary button

**Variants:**
- `empty`: Content explicitly empty
- `error`: Content failed to load
- `loading`: Content is being fetched
- `offline`: Device is disconnected

---

### 4.8 Error States

**Purpose:** Communicate failures and recovery options.

**Specifications:**
- Icon: Error semantic color
- Title: Brief, specific description
- Message: What happened + what to do
- Actions: Retry button, alternative navigation

**Error Banner:**
- Full-width alert at top of content area
- Dismissible when appropriate
- Links to resolution when available

---

### 4.9 Loading Indicators

#### 4.9.1 Spinner

**Purpose:** Indeterminate loading for buttons, inline content.

**Specifications:**
- Small: 20px diameter (inline)
- Medium: 24px diameter (cards)
- Large: 40px diameter (full-screen)
- Color: `primary` or contextual

#### 4.9.2 Skeleton Screens

**Purpose:** Indicate content structure while loading.

**Specifications:**
- Shape: Matches expected content layout
- Color: `onSurface` @ 8% (light) or @ 12% (dark)
- Animation: Shimmer effect, 1200ms duration
- Text heights match typography scale

**Text Skeleton Heights:**
- XS: 12px
- SM: 14px
- MD: 16px
- LG: 18px
- XL: 20px
- Display: 24px
- Hero: 28px

---

## 5. Motion and Interaction System

### 5.1 Motion Philosophy

Motion in MySched serves three purposes:

1. **Feedback**: Confirm that user input was received
2. **Orientation**: Help users understand spatial relationships
3. **Continuity**: Smooth transitions between states reduce cognitive load

Motion is never decorative. Every animation must justify its existence through improved usability or clarity.

#### When Motion Is Used

- Responding to user input (button presses, toggles)
- Transitioning between screens
- Revealing or hiding content
- Indicating loading or synchronization
- Celebrating task completion

#### When Motion Is Avoided

- When reduced motion is enabled
- During data-intensive operations where delays compound
- For static, informational content
- When motion would obscure information

### 5.2 Duration Tokens

Optimized for 90-120Hz displays. All durations are frame-count aware.

| Token | Duration | Frames @120Hz | Usage |
|-------|----------|---------------|-------|
| `micro` | 50ms | 6 | Ripples, state changes |
| `instant` | 83ms | 10 | Button press feedback |
| `fast` | 100ms | 12 | Tooltips, dropdowns |
| `quick` | 150ms | 18 | Cards, small panels |
| `standard` | 200ms | 24 | Page elements, modals |
| `medium` | 300ms | 36 | Complex reveals |
| `slow` | 400ms | 48 | Page transitions, hero |
| `deliberate` | 500ms | 60 | Onboarding sequences |
| `long` | 800ms | 96 | Loading states |
| `extended` | 1200ms | 144 | Shimmer effects |
| `prolonged` | 1500ms | 180 | Breathing effects |

### 5.3 Easing Curves

| Token | Cubic Bezier | Usage |
|-------|--------------|-------|
| `ease` | (0.25, 0.1, 0.25, 1.0) | Standard animations |
| `easeOut` | (0.0, 0.0, 0.2, 1.0) | Entrances, reveals |
| `easeIn` | (0.4, 0.0, 1.0, 1.0) | Exits, dismissals |
| `easeInOut` | (0.4, 0.0, 0.2, 1.0) | Reversible animations |
| `decelerate` | (0.0, 0.0, 0.1, 1.0) | Quick stops |
| `accelerate` | (0.4, 0.0, 0.6, 1.0) | Sharp emphasis |
| `overshoot` | (0.34, 1.56, 0.64, 1.0) | Bouncy entrances |
| `anticipate` | (0.36, 0.0, 0.66, -0.56) | Exits with wind-up |
| `snapBack` | (0.175, 0.885, 0.32, 1.275) | Elastic feel |
| `smoothStep` | (0.4, 0.0, 0.6, 1.0) | State transitions |

### 5.4 Spring Physics

For natural, responsive animations.

| Spring Type | Mass | Stiffness | Damping | Usage |
|-------------|------|-----------|---------|-------|
| `snappySpring` | 1.0 | 400 | 30 | Buttons, toggles |
| `responsiveSpring` | 1.0 | 300 | 25 | Cards, panels |
| `smoothSpring` | 1.0 | 200 | 22 | Sheets, modals |
| `bouncySpring` | 1.0 | 350 | 15 | FAB, success states |
| `gentleSpring` | 1.0 | 150 | 20 | Hover, focus |

### 5.5 Scale Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `scaleNone` | 1.0 | Default state |
| `scaleHoverMicro` | 1.015 | Standard card hover |
| `scaleHoverSm` | 1.02 | Interactive card hover |
| `scalePressSubtle` | 0.985 | Large surface press |
| `scalePressCard` | 0.98 | Standard card press |
| `scalePressInteractive` | 0.97 | Interactive card press |
| `scalePressLight` | 0.975 | Light press feedback |
| `scalePress` | 0.9 | Standard button press |
| `scalePressDeep` | 0.88 | FAB press |
| `scaleEmphasis` | 1.08 | Selected/active state |
| `scaleEntry` | 0.95 | Appear animation start |
| `scaleEntrySubtle` | 0.96 | Subtle entrance |
| `scaleExit` | 1.04 | Dismiss animation end |

### 5.6 Stagger Delays

For list and sequence animations.

| Token | Duration | Usage |
|-------|----------|-------|
| `staggerFast` | 30ms | Quick lists |
| `staggerStandard` | 50ms | Most lists |
| `staggerSlow` | 80ms | Dramatic reveals |
| `staggerTyping` | 120ms | Typing indicators |

### 5.7 Motion Patterns

#### Page Transitions

**Fade-Through (Default):**
- Duration: 350ms
- Entering: Fade in from 0, scale from 0.96, slight slide up (2%)
- Exiting: Fade out, scale to 1.04
- Curve: easeOut

#### List Item Entrance

- Delay: Index * 50ms (staggerStandard)
- Duration: 200ms
- Effect: Fade in + slide from 5% below
- Curve: easeOut

#### Button Press

- Press: Scale to 0.96, 80ms, decelerate curve
- Release: Scale to 1.0, 200ms, overshoot curve

#### Success Confirmation

- Duration: 300ms
- Effect: Scale up to 1.08 with bounce
- Spring: bouncySpring

#### Error Feedback

- Duration: 200ms
- Effect: Subtle horizontal shake (3 oscillations)
- Visual: Error color border flash

#### Offline to Online Sync

- Indicator: Pulse animation while syncing
- Completion: Fade out success indicator after 2s
- Duration: prolonged (1500ms) for sync pulse

### 5.8 Reduced Motion

When system prefers-reduced-motion is enabled:

- All scale animations become instant (no transition)
- Fade animations reduce to 100ms maximum
- Slide animations are replaced with crossfades
- Stagger delays are eliminated
- Spring animations become linear
- Continuous animations (shimmer, pulse) are static

---

## 6. Accessibility Standards

MySched adheres to WCAG 2.1 Level AA compliance as a minimum standard.

### 6.1 Color Contrast Requirements

| Content Type | Minimum Ratio | Measurement |
|--------------|---------------|-------------|
| Normal text | 4.5:1 | Foreground vs background |
| Large text (18pt+) | 3:1 | Foreground vs background |
| UI components | 3:1 | Against adjacent colors |
| Focus indicators | 3:1 | Against background |
| Icons (informational) | 3:1 | Against background |

All color tokens have been validated against these requirements.

### 6.2 Focus Behavior

**Keyboard Navigation:**
- All interactive elements are reachable via Tab
- Focus order follows visual reading order
- Focus is never trapped (except in modals, with Escape exit)
- Skip links provided for repetitive navigation

**Focus Indicators:**
- Visible ring or outline on focused elements
- Minimum 2px width
- Color: Primary or high-contrast alternative
- Never removed, only styled appropriately

### 6.3 Screen Reader Support

**Labels:**
- All interactive elements have accessible names
- Form inputs have associated labels
- Images have alt text (empty for decorative)
- Icon buttons have aria-label equivalents

**Announcements:**
- Loading states announced
- Errors announced with role="alert"
- Success messages announced with role="status"
- Dynamic content changes announced via live regions

**Semantic Structure:**
- Proper heading hierarchy (h1 > h2 > h3)
- Lists use semantic list elements
- Tables have headers and scope
- Landmarks used for major sections

### 6.4 Touch Target Sizing

All interactive elements meet minimum touch target requirements:

| Element Type | Minimum Size |
|--------------|--------------|
| Buttons | 48x48px |
| List items | 48px height |
| Icons (tappable) | 48x48px touch area |
| Close buttons | 44x44px minimum |

Adjacent targets must have minimum 8px spacing.

### 6.5 Motion Reduction

When user enables reduced motion:
- Animations shorten to < 100ms
- Scale transitions disabled
- Slide transitions become fades
- Continuous animations become static
- Parallax effects disabled

Implementation via `prefers-reduced-motion` media query.

### 6.6 Text Scaling

- Application supports up to 200% font scaling
- Layouts reflow rather than overlap
- Critical text never truncated below readable size
- Minimum body text: 14px at 100% scale

---

## 7. Platform-Specific Guidelines

### 7.1 Mobile (Flutter)

#### Material Design Alignment

MySched uses Material 3 as its foundation while maintaining platform-agnostic visual identity. Key decisions:

- **Color Scheme**: Custom ColorScheme built from design tokens
- **Typography**: Custom font family instead of Material defaults
- **Components**: Material components restyled via theme
- **Navigation**: Bottom navigation with centered FAB

#### Gesture Behavior

| Gesture | Location | Action |
|---------|----------|--------|
| Pull-to-refresh | Scrollable lists | Refresh content |
| Swipe left | List items | Delete/archive action |
| Long press | Cards, items | Context menu or selection |
| Pinch | Not used | Avoid zoom confusion |

#### Haptics Usage

| Event | Haptic Type |
|-------|-------------|
| Button press | Light impact |
| Toggle change | Medium impact |
| Destructive action | Heavy impact |
| Success | Success pattern |
| Error | Error pattern (double buzz) |

#### Offline State UX

**Visual Indicators:**
- Persistent banner when offline
- Grayed sync status indicator
- Pending changes badge

**Behavior:**
- All read operations from local cache
- Write operations queued for sync
- Clear "Waiting to sync" messaging
- Automatic sync on reconnection
- Manual refresh available

#### Notification UI

- System notification channel configuration
- Grouped notifications by type
- Alarm notifications use fullscreen intent
- Reminder notifications include quick actions
- Silent sync notifications for background updates

### 7.2 Web (Next.js)

#### Keyboard Navigation

All functionality accessible via keyboard:

| Key | Action |
|-----|--------|
| Tab | Move focus forward |
| Shift+Tab | Move focus backward |
| Enter/Space | Activate focused element |
| Escape | Close modal/dropdown |
| Arrow keys | Navigate within components |

#### Hover vs Tap Differences

| Behavior | Desktop (Hover) | Mobile (Touch) |
|----------|-----------------|----------------|
| Card preview | Show on hover | Show on long press |
| Tooltips | Delayed hover | Not shown (info in UI) |
| Dropdown trigger | Hover or click | Tap only |
| Button feedback | Hover state + click | Press state only |

#### Scroll Behavior

- Smooth scroll for anchor links
- Scroll restoration on navigation
- Infinite scroll with loading indicator
- Keyboard-accessible scrolling
- Focus management after scroll operations

#### Performance Constraints

- Initial bundle < 150KB gzipped
- Largest contentful paint < 2.5s
- Time to interactive < 3s
- Cumulative layout shift < 0.1
- Images lazy-loaded below fold

#### Responsive Breakpoints (Web)

| Breakpoint | Width | Layout |
|------------|-------|--------|
| Mobile | < 640px | Single column |
| Tablet | 640-1024px | Constrained content |
| Desktop | > 1024px | Max-width content area |

---

## 8. Data and State Design

### 8.1 Loading States

**Initial Load:**
- Show skeleton screens matching content structure
- Animate shimmer effect during load
- Transition to content with fade

**Refresh:**
- Pull-to-refresh indicator at top
- Content remains visible during refresh
- Silent failure retries before showing error

**Pagination:**
- Loading indicator at list bottom
- Load more on scroll near end
- Disable further loading at end of data

### 8.2 Empty States

Each empty state clearly communicates:

1. **What is empty**: "No classes scheduled"
2. **Why it matters**: Brief context if needed
3. **What to do**: Action button or guidance

**Variants by Cause:**
- Fresh account: Welcome message + setup prompt
- Filtered empty: Adjust filters suggestion
- Deleted content: Undo option if recent
- Future empty: Expected state, no action

### 8.3 Error States

**Network Errors:**
- Clear "No connection" message
- Retry button
- Cached data indication

**Server Errors:**
- Generic message (don't expose internals)
- Support contact for persistent issues
- Automatic retry with backoff

**Validation Errors:**
- Inline under relevant fields
- Summary at form top for multiple
- Clear, specific fix instructions

### 8.4 Offline-First UX Patterns

**Data Availability:**
- Critical data cached locally
- Cache-first reads, background refresh
- Expiry-based invalidation

**Write Operations:**
- Optimistic UI updates
- Queued sync when offline
- Conflict detection on sync
- User-resolvable conflicts surfaced

**Sync Status:**
- Discrete sync indicator (not blocking)
- "Last synced" timestamp
- Manual refresh option always available

### 8.5 Sync Conflict Handling

When local and remote data conflict:

1. Attempt automatic merge for non-conflicting fields
2. Prefer most recent modification by default
3. Surface irreconcilable conflicts to user
4. Provide clear "Keep local" / "Keep server" options
5. Log resolution for support debugging

### 8.6 User Reassurance Patterns

**Save Confirmation:**
- Brief "Saved" toast for successful writes
- No confirmation for auto-save

**Destructive Preview:**
- Show what will be deleted/changed
- Explicit confirmation for bulk actions
- Undo option when possible

**Loading Confidence:**
- Progress indicators for long operations
- Estimated time when determinable
- Cancel option for interruptible tasks

---

## 9. Iconography and Imagery

### 9.1 Icon Style Rules

MySched uses a consistent icon style across all platforms:

**General Characteristics:**
- Style: Outlined (primary) with selective filled variants
- Stroke weight: 1.5-2px depending on size
- Corner radius: Slightly rounded for friendly feel
- Optical sizing: Icons designed for target display size

**Size Scale:**

| Token | Size | Usage |
|-------|------|-------|
| `bullet` | 8px | Inline bullets |
| `check` | 10px | Checkmarks in compact contexts |
| `xs` | 14px | Inline with small text |
| `sm` | 16px | Inline icons, secondary actions |
| `md` | 20px | Standard interactive icons |
| `lg` | 24px | Primary icons, navigation |
| `xl` | 28px | Emphasized icons |
| `fab` | 32px | FAB icons |
| `xxl` | 40px | Large decorative icons |
| `display` | 64px | Hero/empty state illustrations |

### 9.2 Filled vs Outlined Usage

| Context | Style |
|---------|-------|
| Navigation (inactive) | Outlined |
| Navigation (active) | Filled |
| Toolbar actions | Outlined |
| Status indicators | Filled |
| Empty state illustrations | Outlined or light filled |
| Semantic indicators | Filled (success, error, warning) |

### 9.3 Icon Color Usage

- **Interactive icons**: `onSurfaceVariant` (inactive), `primary` (active)
- **Semantic icons**: Use corresponding semantic color
- **Decorative icons**: `onSurfaceVariant` @ 60% opacity
- **On colored backgrounds**: `onPrimary` or `onSurface` as appropriate

### 9.4 Screenshot Guidelines

For documentation, marketing, and support:

- Device frames: Use official platform device mocks
- Screen content: Use sample data, never real user data
- Highlights: Use primary color with 20% opacity overlays
- Annotations: Use `caption` typography, `onSurface` color
- Format: PNG for interface, WebP for documentation

### 9.5 Illustration Usage

MySched uses minimal illustration. When used:

- Style: Line art consistent with icon style
- Purpose: Empty states, onboarding, error states
- Complexity: Simple, single-focal-point compositions
- Color: Monochromatic or limited palette (primary + neutral)
- Size: Contained within 64-120px bounds

---

## 10. Governance and Evolution

### 10.1 Adding New Components

New components follow this approval process:

1. **Proposal**: Document use case, variants, and behavior
2. **Design Review**: Evaluate consistency with design principles
3. **Accessibility Review**: Verify WCAG compliance
4. **Engineering Review**: Assess implementation feasibility
5. **Documentation**: Complete component template
6. **Implementation**: Build in Flutter and/or Next.js
7. **QA Verification**: Test all states and accessibility
8. **Merge**: Component becomes part of design system

### 10.2 Versioning Rules

The design system follows semantic versioning:

- **Major (X.0.0)**: Breaking changes to existing components
- **Minor (0.X.0)**: New components, non-breaking additions
- **Patch (0.0.X)**: Bug fixes, documentation updates

Each version includes:
- Changelog with all modifications
- Migration guide for breaking changes
- Updated component documentation

### 10.3 Breaking Change Policy

Breaking changes are changes that:
- Modify component APIs
- Change default visual appearance significantly
- Alter interaction behavior
- Remove existing tokens or components

**Process:**
1. Announce deprecation with migration timeline
2. Provide migration documentation
3. Maintain deprecated version for one release cycle
4. Remove deprecated version in next major release

### 10.4 Design Debt Handling

Design debt is tracked and prioritized:

**Identification:**
- Components not meeting current standards
- Inconsistent usage patterns
- Accessibility gaps
- Technical limitations requiring workarounds

**Prioritization:**
1. Accessibility issues (highest priority)
2. Usability problems affecting key flows
3. Visual inconsistencies
4. Technical debt without user impact

**Resolution:**
- Documented in backlog with severity
- Addressed during dedicated cleanup sprints
- Reviewed quarterly for systemic issues

### 10.5 Review Checklist

Before any design system change is merged:

**Design Quality:**
- [ ] Follows established design principles
- [ ] Consistent with existing visual language
- [ ] Token usage instead of hardcoded values
- [ ] Responsive behavior defined

**Accessibility:**
- [ ] Color contrast verified
- [ ] Touch targets meet minimums
- [ ] Screen reader testing completed
- [ ] Keyboard navigation functional
- [ ] Reduced motion variant defined

**Documentation:**
- [ ] Component template fully completed
- [ ] All variants documented
- [ ] Do/Don't examples provided
- [ ] Code examples accurate

**Implementation:**
- [ ] Flutter implementation matches spec
- [ ] Web implementation matches spec
- [ ] Cross-platform consistency verified
- [ ] Performance impact assessed

---

## Appendix A: Token Quick Reference

### Colors (Primary)

```
primary:          #0066FF
positive:         #1FB98F (light) / #44E5BC (dark)
warning:          #FFAE04
danger:           #E54B4F
info:             #2D61EF
```

### Spacing

```
xs:   4px    |   lg:   16px   |   xxxl: 32px
sm:   8px    |   xl:   20px   |   quad: 40px
md:  12px    |   xxl:  24px
```

### Typography

```
brand:     42px / Bold
display:   32px / Bold
headline:  26px / SemiBold
title:     20px / SemiBold
subtitle:  16px / Medium
body:      16px / Regular
caption:   12px / Medium
micro:     10px / Medium
```

### Radius

```
sm:    8px     |   lg:    16px    |   button: 26px
md:   12px     |   sheet: 20px    |   pill:  999px
```

### Motion

```
fast:     100ms   |   slow:      400ms
standard: 200ms   |   deliberate: 500ms
medium:   300ms   |   long:      800ms
```

---

## Appendix B: File Organization

```
lib/ui/
├── theme/
│   ├── app_theme.dart          # ThemeData builders
│   ├── card_styles.dart        # Card-specific styling
│   ├── motion.dart             # Animation presets
│   ├── tokens.dart             # Token aggregator
│   └── tokens/
│       ├── colors.dart         # Semantic colors
│       ├── interaction.dart    # Touch targets, gestures
│       ├── layout.dart         # Breakpoints, constraints
│       ├── motion.dart         # Duration, easing tokens
│       ├── opacity.dart        # Transparency values
│       ├── radius.dart         # Border radius scale
│       ├── responsive.dart     # Responsive breakpoints
│       ├── shadows.dart        # Shadow definitions
│       ├── sizing.dart         # Component dimensions
│       ├── spacing.dart        # Spacing scale
│       ├── typography.dart     # Text styles
│       └── urgency.dart        # Alert levels
└── kit/
    └── [72 component files]
```

---

This document represents the definitive source of truth for the MySched design system. All implementations should reference this documentation, and any deviations require explicit approval through the governance process.

For questions or contributions, contact the design system maintainers.
