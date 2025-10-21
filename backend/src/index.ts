import express, { Express, Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth';
import foldersRoutes from './routes/folders';
import flashcardsRoutes from './routes/flashcards';

dotenv.config();

const app: Express = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/folders', foldersRoutes);
app.use('/api/flashcards', flashcardsRoutes);

// Basic route
app.get('/', (req: Request, res: Response) => {
  res.json({ message: 'Flashcard API Server' });
});

// Start server
app.listen(port, () => {
  console.log(`⚡️[server]: Server is running at http://localhost:${port}`);
});
