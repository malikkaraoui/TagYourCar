import { initializeApp } from "firebase-admin/app";

initializeApp();

export { hashPlate } from "./hash-plate";
export { verifyOwnership } from "./verify-ownership";
export { deletePlate } from "./delete-plate";
