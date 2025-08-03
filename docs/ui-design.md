# Flashcard App - UI/UX Design Specifications

## Design Philosophy

**Modern, Mobile-First, Accessible**
- Clean, minimalist interface
- Smooth, delightful animations
- Dark/light mode support
- Touch-friendly interactions
- Fast, responsive performance

## Responsive Design Strategy

### Mobile-First Approach
```
📱 Mobile (320px+)     → Primary design target
📱 Large Mobile (480px+) → Optimized layouts
📊 Tablet (768px+)     → Enhanced spacing
💻 Desktop (1024px+)   → Full feature set
🖥️  Large Desktop (1440px+) → Optimal viewing
```

### Breakpoint System (Tailwind CSS)
- `sm`: 640px and up
- `md`: 768px and up  
- `lg`: 1024px and up
- `xl`: 1280px and up
- `2xl`: 1536px and up

## Visual Design System

### Color Palette

#### Light Mode
```css
Primary Colors:
- Blue-600: #2563eb (primary actions, links)
- Blue-500: #3b82f6 (hover states)
- Blue-50: #eff6ff (light backgrounds)

Neutral Colors:
- Gray-900: #111827 (primary text)
- Gray-600: #4b5563 (secondary text)
- Gray-100: #f3f4f6 (card backgrounds)
- White: #ffffff (main background)

Accent Colors:
- Green-500: #10b981 (success states)
- Red-500: #ef4444 (delete actions)
- Amber-500: #f59e0b (warnings)
```

#### Dark Mode
```css
Primary Colors:
- Blue-500: #3b82f6 (primary actions)
- Blue-400: #60a5fa (hover states)
- Blue-950: #172554 (dark backgrounds)

Neutral Colors:
- Gray-100: #f3f4f6 (primary text)
- Gray-400: #9ca3af (secondary text)
- Gray-800: #1f2937 (card backgrounds)
- Gray-900: #111827 (main background)

Accent Colors:
- Green-400: #34d399 (success states)
- Red-400: #f87171 (delete actions)
- Amber-400: #fbbf24 (warnings)
```

### Typography

#### Font Stack
```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
```

#### Text Scales
- **Display**: 2.25rem (36px) - Page titles
- **Heading 1**: 1.875rem (30px) - Section headers
- **Heading 2**: 1.5rem (24px) - Card titles
- **Heading 3**: 1.25rem (20px) - Subsections
- **Body**: 1rem (16px) - Main content
- **Small**: 0.875rem (14px) - Secondary text
- **Tiny**: 0.75rem (12px) - Captions, timestamps

### Spacing & Layout

#### Spacing Scale (Tailwind)
- `1`: 0.25rem (4px)
- `2`: 0.5rem (8px)
- `3`: 0.75rem (12px)
- `4`: 1rem (16px)
- `6`: 1.5rem (24px)
- `8`: 2rem (32px)
- `12`: 3rem (48px)
- `16`: 4rem (64px)

#### Border Radius
- **Small**: 0.375rem (6px) - Buttons, inputs
- **Medium**: 0.5rem (8px) - Cards, modals
- **Large**: 0.75rem (12px) - Main containers
- **Full**: 9999px - Pills, avatars

### Component Design

#### Buttons
```css
Primary Button:
- Background: blue-600 → blue-500 (hover)
- Text: white
- Padding: py-3 px-6 (mobile), py-2 px-4 (desktop)
- Border radius: rounded-lg
- Transition: all 150ms ease

Secondary Button:
- Background: transparent
- Border: 2px solid blue-600
- Text: blue-600
- Hover: background blue-50

Danger Button:
- Background: red-600 → red-500 (hover)
- Text: white
```

#### Cards
```css
Flashcard:
- Background: white (light) / gray-800 (dark)
- Border radius: rounded-xl
- Shadow: shadow-sm → shadow-md (hover)
- Padding: p-6
- Transition: transform 150ms, shadow 150ms
- Hover: transform scale(1.02)

Folder Card:
- Similar to flashcard
- Border-left: 4px solid blue-500
- Hover: slight translate-y animation
```

#### Form Elements
```css
Input Fields:
- Border: 2px solid gray-300 → blue-500 (focus)
- Border radius: rounded-lg
- Padding: py-3 px-4
- Transition: border-color 150ms
- Focus ring: ring-2 ring-blue-500 ring-opacity-50

Text Areas:
- Same as inputs
- Min height: 120px
- Resize: vertical only
```

## Animation Guidelines

### Micro-Interactions
```css
Hover Effects:
- Duration: 150ms
- Easing: ease-out
- Scale: 1.02-1.05 for cards
- Opacity: 0.8-0.9 for buttons

Focus States:
- Ring animations
- Color transitions
- Duration: 150ms

Loading States:
- Skeleton screens
- Pulse animations
- Spinner for actions
```

### Page Transitions (Framer Motion)
```css
Page Enter:
- initial: { opacity: 0, y: 20 }
- animate: { opacity: 1, y: 0 }
- transition: { duration: 0.3, ease: "easeOut" }

Modal Animations:
- initial: { opacity: 0, scale: 0.9 }
- animate: { opacity: 1, scale: 1 }
- exit: { opacity: 0, scale: 0.9 }
- transition: { duration: 0.2 }

Card Animations:
- Stagger children by 50ms
- Smooth flip animations for flashcards
- Drag-to-reorder with spring physics
```

## Mobile-Specific Considerations

### Touch Targets
- Minimum size: 44px × 44px
- Comfortable spacing between interactive elements
- Larger buttons on mobile: py-3 px-6

### Gestures
- Swipe to flip flashcards
- Pull-to-refresh on card lists
- Swipe left/right for folder navigation
- Long press for context menus

### Navigation
```css
Mobile Navigation:
- Bottom tab bar (sticky)
- Hamburger menu for secondary actions
- Floating action button (FAB) for "Add Card"

Tablet/Desktop:
- Side navigation panel
- Top navigation bar
- Keyboard shortcuts support
```

## Component Library Structure

### Core Components
```
components/
├── ui/                    # Base UI components
│   ├── Button.tsx
│   ├── Input.tsx
│   ├── Modal.tsx
│   ├── Card.tsx
│   └── Badge.tsx
├── layout/               # Layout components
│   ├── Header.tsx
│   ├── Sidebar.tsx
│   ├── Navigation.tsx
│   └── Container.tsx
├── flashcard/           # Flashcard-specific
│   ├── FlashcardList.tsx
│   ├── FlashcardItem.tsx
│   ├── FlashcardEditor.tsx
│   └── FlashcardViewer.tsx
├── folder/              # Folder management
│   ├── FolderList.tsx
│   ├── FolderCard.tsx
│   └── FolderEditor.tsx
└── auth/                # Authentication
    ├── LoginForm.tsx
    ├── RegisterForm.tsx
    └── AuthLayout.tsx
```

## Accessibility Features

### WCAG 2.1 AA Compliance
- Color contrast ratios ≥ 4.5:1
- Keyboard navigation support
- Screen reader compatibility
- Focus indicators
- Alt text for images
- Semantic HTML structure

### Responsive Text
- Font sizes scale with device
- Line heights optimized for reading
- Adequate spacing between elements

## Performance Considerations

### Optimization Strategies
- Lazy loading for large card lists
- Virtual scrolling for 100+ cards
- Image optimization and lazy loading
- Code splitting by routes
- Progressive loading with skeletons

### Bundle Size
- Tree-shake unused Tailwind classes
- Optimize animation libraries
- Compress images and assets

## Implementation Notes

### Tailwind CSS Setup
```css
/* Custom theme extensions */
module.exports = {
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
      }
    }
  }
}
```

### Framer Motion Patterns
```tsx
// Page transitions
const pageVariants = {
  initial: { opacity: 0, y: 20 },
  in: { opacity: 1, y: 0 },
  out: { opacity: 0, y: -20 }
}

// Card hover effects
const cardVariants = {
  hover: { 
    scale: 1.02,
    transition: { duration: 0.15 }
  }
}
```

This design system ensures a modern, responsive, and delightful user experience across all devices while maintaining excellent performance and accessibility.
