import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import User from "../models/User.js";

const saltRounds = 10;

/* Register User */
export const register = async (req, res) => {
    try {
        const {
            username,
            email,
            password,
        } = req.body;

        const salt = await bcrypt.genSalt(saltRounds);
        const passwordHash = await bcrypt.hash(password, salt);

        const newUser = new User({
            username,
            email,
            password: passwordHash,
        });

        const savedNewUser = await newUser.save();

        res.status(201).json(savedNewUser);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

/* Login User */
export const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const userFound = await User.findOne({ email: email });
        if (!userFound) {
            res.status(500).json({ error: err.message });
        }

        const isPasswordMatch = await bcrypt.compare(password, userFound.password);
        if (!isPasswordMatch) {
            res.status(500).json({ error: err.message });
        }

        const token = jwt.sign({
            id: userFound._id,
            username: userFound.username,
            email: userFound.email
        }, process.env.JWT_SECRET);

        delete userFound.password;
        res.status(201).json({ token, userFound });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

/* Verify Token for Login */
export const verifyToken = async (req, res) => {
    try {
        let token = req.header("Authorization");

        if (!token) {
            return res.status(403).send("Access Denied");
        }

        if (token.startsWith("Bearer ")) {
            token = token.slice(7).trimLeft();
        }

        const verified = jwt.verify(token, process.env.JWT_SECRET);

        return res.status(200).json({
            message: "Access allowed",
            user: verified
        })

    } catch (err) {
        if (err instanceof jwt.JsonWebTokenError) {
            return res.status(401).json({
                message: "Access denied - invalid token"
            });
        }
        return res.status(500).json({
            message: "An error occurred",
            error: err.message
        });
    }
}