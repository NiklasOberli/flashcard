# Database Schema Design

## Core Entities

```
Users
├── id (Primary Key)
├── email (Unique)
├── password_hash
├── created_at
└── updated_at

Folders
├── id (Primary Key)
├── user_id (Foreign Key → Users.id)
├── name (e.g., "Learning", "Backlog", "Remembered")
├── created_at
└── updated_at

Flashcards
├── id (Primary Key)
├── user_id (Foreign Key → Users.id)
├── folder_id (Foreign Key → Folders.id)
├── front_text
├── back_text
├── created_at
└── updated_at
```

## Relationships
- One User → Many Folders (1:N)
- One User → Many Flashcards (1:N)
- One Folder → Many Flashcards (1:N)
