import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, authenticateToken } from '../middleware/auth';

const router = Router();
const prisma = new PrismaClient();

/**
 * GET /api/folders
 * Get all folders for authenticated user
 */
router.get('/', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.userId!;

    const folders = await prisma.folder.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: {
        _count: {
          select: { flashcards: true },
        },
      },
    });

    res.json({ folders });
  } catch (error) {
    console.error('Error fetching folders:', error);
    res.status(500).json({ error: 'Failed to fetch folders' });
  }
});

/**
 * POST /api/folders
 * Create a new folder
 */
router.post('/', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.userId!;
    const { name } = req.body;

    // Validate input
    if (!name || typeof name !== 'string' || name.trim().length === 0) {
      res.status(400).json({ error: 'Folder name is required' });
      return;
    }

    if (name.length > 100) {
      res.status(400).json({ error: 'Folder name must be 100 characters or less' });
      return;
    }

    // Create folder
    const folder = await prisma.folder.create({
      data: {
        userId,
        name: name.trim(),
      },
    });

    res.status(201).json({ folder });
  } catch (error) {
    console.error('Error creating folder:', error);
    res.status(500).json({ error: 'Failed to create folder' });
  }
});

/**
 * PUT /api/folders/:id
 * Update folder name
 */
router.put('/:id', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.userId!;
    const { id } = req.params;
    const { name } = req.body;

    // Validate input
    if (!name || typeof name !== 'string' || name.trim().length === 0) {
      res.status(400).json({ error: 'Folder name is required' });
      return;
    }

    if (name.length > 100) {
      res.status(400).json({ error: 'Folder name must be 100 characters or less' });
      return;
    }

    // Check if folder exists and belongs to user
    const existingFolder = await prisma.folder.findUnique({
      where: { id },
    });

    if (!existingFolder) {
      res.status(404).json({ error: 'Folder not found' });
      return;
    }

    if (existingFolder.userId !== userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }

    // Update folder
    const folder = await prisma.folder.update({
      where: { id },
      data: { name: name.trim() },
    });

    res.json({ folder });
  } catch (error) {
    console.error('Error updating folder:', error);
    res.status(500).json({ error: 'Failed to update folder' });
  }
});

/**
 * DELETE /api/folders/:id
 * Delete a folder (and all its flashcards due to cascade)
 */
router.delete('/:id', authenticateToken, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.userId!;
    const { id } = req.params;

    // Check if folder exists and belongs to user
    const existingFolder = await prisma.folder.findUnique({
      where: { id },
    });

    if (!existingFolder) {
      res.status(404).json({ error: 'Folder not found' });
      return;
    }

    if (existingFolder.userId !== userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }

    // Delete folder (flashcards will be cascade deleted)
    await prisma.folder.delete({
      where: { id },
    });

    res.json({ message: 'Folder deleted successfully' });
  } catch (error) {
    console.error('Error deleting folder:', error);
    res.status(500).json({ error: 'Failed to delete folder' });
  }
});

export default router;
