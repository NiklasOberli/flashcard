import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, authenticateToken } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

/**
 * GET /api/flashcards
 * Get all flashcards for authenticated user, optionally filtered by folder
 * Query params: folder_id (optional)
 */
router.get('/', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.userId!;
    const { folder_id } = req.query;

    // Build where clause
    const where: any = { userId };
    if (folder_id && typeof folder_id === 'string') {
      where.folderId = folder_id;
    }

    const flashcards = await prisma.flashcard.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        folder: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    res.json({ flashcards });
  } catch (error) {
    console.error('Error fetching flashcards:', error);
    res.status(500).json({ error: 'Failed to fetch flashcards' });
  }
});

/**
 * POST /api/flashcards
 * Create a new flashcard
 */
router.post('/', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.userId!;
    const { folderId, frontText, backText } = req.body;

    // Validate input
    if (!folderId || typeof folderId !== 'string') {
      res.status(400).json({ error: 'Folder ID is required' });
      return;
    }

    if (!frontText || typeof frontText !== 'string' || frontText.trim().length === 0) {
      res.status(400).json({ error: 'Front text is required' });
      return;
    }

    if (!backText || typeof backText !== 'string' || backText.trim().length === 0) {
      res.status(400).json({ error: 'Back text is required' });
      return;
    }

    if (frontText.length > 1000) {
      res.status(400).json({ error: 'Front text must be 1000 characters or less' });
      return;
    }

    if (backText.length > 1000) {
      res.status(400).json({ error: 'Back text must be 1000 characters or less' });
      return;
    }

    // Check if folder exists and belongs to user
    const folder = await prisma.folder.findUnique({
      where: { id: folderId },
    });

    if (!folder) {
      res.status(404).json({ error: 'Folder not found' });
      return;
    }

    if (folder.userId !== userId) {
      res.status(403).json({ error: 'Access denied to this folder' });
      return;
    }

    // Create flashcard
    const flashcard = await prisma.flashcard.create({
      data: {
        userId,
        folderId,
        frontText: frontText.trim(),
        backText: backText.trim(),
      },
      include: {
        folder: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    res.status(201).json({ flashcard });
  } catch (error) {
    console.error('Error creating flashcard:', error);
    res.status(500).json({ error: 'Failed to create flashcard' });
  }
});

/**
 * PUT /api/flashcards/:id
 * Update a flashcard
 */
router.put('/:id', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.userId!;
    const { id } = req.params;
    const { frontText, backText } = req.body;

    // Validate input
    if (!frontText || typeof frontText !== 'string' || frontText.trim().length === 0) {
      res.status(400).json({ error: 'Front text is required' });
      return;
    }

    if (!backText || typeof backText !== 'string' || backText.trim().length === 0) {
      res.status(400).json({ error: 'Back text is required' });
      return;
    }

    if (frontText.length > 1000) {
      res.status(400).json({ error: 'Front text must be 1000 characters or less' });
      return;
    }

    if (backText.length > 1000) {
      res.status(400).json({ error: 'Back text must be 1000 characters or less' });
      return;
    }

    // Check if flashcard exists and belongs to user
    const existingFlashcard = await prisma.flashcard.findUnique({
      where: { id },
    });

    if (!existingFlashcard) {
      res.status(404).json({ error: 'Flashcard not found' });
      return;
    }

    if (existingFlashcard.userId !== userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }

    // Update flashcard
    const flashcard = await prisma.flashcard.update({
      where: { id },
      data: {
        frontText: frontText.trim(),
        backText: backText.trim(),
      },
      include: {
        folder: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    res.json({ flashcard });
  } catch (error) {
    console.error('Error updating flashcard:', error);
    res.status(500).json({ error: 'Failed to update flashcard' });
  }
});

/**
 * DELETE /api/flashcards/:id
 * Delete a flashcard
 */
router.delete('/:id', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.userId!;
    const { id } = req.params;

    // Check if flashcard exists and belongs to user
    const existingFlashcard = await prisma.flashcard.findUnique({
      where: { id },
    });

    if (!existingFlashcard) {
      res.status(404).json({ error: 'Flashcard not found' });
      return;
    }

    if (existingFlashcard.userId !== userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }

    // Delete flashcard
    await prisma.flashcard.delete({
      where: { id },
    });

    res.json({ message: 'Flashcard deleted successfully' });
  } catch (error) {
    console.error('Error deleting flashcard:', error);
    res.status(500).json({ error: 'Failed to delete flashcard' });
  }
});

/**
 * PATCH /api/flashcards/:id/move
 * Move a flashcard to a different folder
 */
router.patch('/:id/move', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.userId!;
    const { id } = req.params;
    const { folderId } = req.body;

    // Validate input
    if (!folderId || typeof folderId !== 'string') {
      res.status(400).json({ error: 'Folder ID is required' });
      return;
    }

    // Check if flashcard exists and belongs to user
    const existingFlashcard = await prisma.flashcard.findUnique({
      where: { id },
    });

    if (!existingFlashcard) {
      res.status(404).json({ error: 'Flashcard not found' });
      return;
    }

    if (existingFlashcard.userId !== userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }

    // Check if target folder exists and belongs to user
    const targetFolder = await prisma.folder.findUnique({
      where: { id: folderId },
    });

    if (!targetFolder) {
      res.status(404).json({ error: 'Target folder not found' });
      return;
    }

    if (targetFolder.userId !== userId) {
      res.status(403).json({ error: 'Access denied to target folder' });
      return;
    }

    // Move flashcard
    const flashcard = await prisma.flashcard.update({
      where: { id },
      data: { folderId },
      include: {
        folder: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    res.json({ flashcard });
  } catch (error) {
    console.error('Error moving flashcard:', error);
    res.status(500).json({ error: 'Failed to move flashcard' });
  }
});

export default router;
