import History from "../models/History.js";

// Add new history entry
export const addHistory = async (req, res) => {
    try {
        const { userId, prompt, recipe } = req.body;

        if (!userId || !prompt || !recipe) {
            return res.status(400).json({ message: "Missing required fields" });
        }

        const newHistory = await History.create({
            userId,
            prompt,
            recipe
        });

        res.status(201).json(newHistory);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

export const getHistory = async (req, res) => {
    try {
        const { userId } = req.params;
        const history = await History.find({ userId }).sort('-createdAt');
        res.json(history);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

export const deleteHistory = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await History.findByIdAndDelete(id);
        if (!deleted) {
            return res.status(404).json({ message: "No history found with the provided ID" });
        }
        res.json({ message: "History deleted successfully" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

export const deleteAllHistory = async (req, res) => {
    try {
        const { userId } = req.params;
        const result = await History.deleteMany({ userId });

        if (result.deletedCount === 0) {
            return res.status(404).json({ message: "No history found for this user" });
        }

        res.json({
            message: `Successfully deleted ${result.deletedCount} history entries`,
            deletedCount: result.deletedCount
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};