import mongoose from "mongoose";

const HistorySchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    prompt: {
        type: String,
        required: true
    },
    recipe: {
        type: String,
        required: true
    },
}, { timestamps: true });

const History = mongoose.model("History", HistorySchema);

export default History;