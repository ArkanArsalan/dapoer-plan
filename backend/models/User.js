import mongoose from "mongoose";

const UserSchema = new mongoose.Schema({
    username: {
        type: String,
        min: 1,
        max: 50,
        required: true,
        unique: true
    },
    email: {
        type: String,
        max: 254,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
}, { timestamps: true });

const User = mongoose.model("User", UserSchema);

export default User;