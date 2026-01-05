/**
 * Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
 * Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
 *
 * Role: Sable (QA Terminator - Bug Killer)
 */

const express = require('express');
const mongoose = require('mongoose');
const { z } = require('zod');

const Task = require('../models/Task');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

const createSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().max(5000).optional(),
  dueDate: z.string().datetime().optional(),
  completed: z.boolean().optional(),
});

const updateSchema = createSchema.partial();

function isValidObjectId(id) {
  return mongoose.Types.ObjectId.isValid(id);
}

router.use(requireAuth);

router.post('/', async (req, res, next) => {
  try {
    const parsed = createSchema.parse(req.body);
    const task = await Task.create({
      title: parsed.title,
      description: parsed.description ?? '',
      dueDate: parsed.dueDate ? new Date(parsed.dueDate) : null,
      completed: parsed.completed ?? false,
      user: req.user.id,
    });

    return res.status(201).json({ task });
  } catch (err) {
    if (err?.name === 'ZodError') return res.status(400).json({ error: { message: 'Invalid input', details: err.errors } });
    return next(err);
  }
});

router.get('/', async (req, res, next) => {
  try {
    const querySchema = z.object({
      completed: z.enum(['true', 'false']).optional(),
      skip: z.coerce.number().int().min(0).optional().default(0),
      limit: z.coerce.number().int().min(1).max(100).optional().default(50),
    });

    const { completed, skip, limit } = querySchema.parse(req.query);
    const filter = { user: req.user.id };
    if (completed === 'true') filter.completed = true;
    if (completed === 'false') filter.completed = false;

    const tasks = await Task.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit);
    return res.status(200).json({ tasks });
  } catch (err) {
    if (err?.name === 'ZodError') return res.status(400).json({ error: { message: 'Invalid query', details: err.errors } });
    return next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    if (!isValidObjectId(id)) return res.status(400).json({ error: { message: 'Invalid id' } });

    const task = await Task.findOne({ _id: id, user: req.user.id });
    if (!task) return res.status(404).json({ error: { message: 'Not found' } });

    return res.status(200).json({ task });
  } catch (err) {
    return next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    if (!isValidObjectId(id)) return res.status(400).json({ error: { message: 'Invalid id' } });

    const parsed = updateSchema.parse(req.body);
    const update = {};
    if (parsed.title !== undefined) update.title = parsed.title;
    if (parsed.description !== undefined) update.description = parsed.description ?? '';
    if (parsed.dueDate !== undefined) update.dueDate = parsed.dueDate ? new Date(parsed.dueDate) : null;
    if (parsed.completed !== undefined) update.completed = parsed.completed;

    const task = await Task.findOneAndUpdate({ _id: id, user: req.user.id }, { $set: update }, { new: true });
    if (!task) return res.status(404).json({ error: { message: 'Not found' } });

    return res.status(200).json({ task });
  } catch (err) {
    if (err?.name === 'ZodError') return res.status(400).json({ error: { message: 'Invalid input', details: err.errors } });
    return next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    if (!isValidObjectId(id)) return res.status(400).json({ error: { message: 'Invalid id' } });

    const result = await Task.deleteOne({ _id: id, user: req.user.id });
    if (!result.deletedCount) return res.status(404).json({ error: { message: 'Not found' } });

    return res.status(204).send();
  } catch (err) {
    return next(err);
  }
});

module.exports = router;