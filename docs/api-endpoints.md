# API Endpoints Design

## Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/me` - Get current user info

## Folders
- `GET /api/folders` - Get user's folders
- `POST /api/folders` - Create new folder
- `PUT /api/folders/:id` - Update folder name
- `DELETE /api/folders/:id` - Delete folder

## Flashcards
- `GET /api/flashcards` - Get all user's flashcards
- `GET /api/flashcards?folder_id=:id` - Get flashcards by folder
- `POST /api/flashcards` - Create new flashcard
- `PUT /api/flashcards/:id` - Update flashcard
- `DELETE /api/flashcards/:id` - Delete flashcard
- `PATCH /api/flashcards/:id/move` - Move card to different folder
