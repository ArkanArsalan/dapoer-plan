import express from "express";
import { addHistory, getHistory, deleteHistory, deleteAllHistory } from "../controllers/history.js";

const router = express.Router();

router.post("/add", addHistory);
router.get("/:userId", getHistory);
router.delete("/:id", deleteHistory)
router.delete("/all/:userId", deleteAllHistory)

export default router;