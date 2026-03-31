import { initializeApp } from "firebase-admin/app";

initializeApp();

export { hashPlate } from "./hash-plate";
export { verifyOwnership } from "./verify-ownership";
export { deletePlate } from "./delete-plate";
export { submitReport } from "./submit-report";
export { onReportCreated } from "./on-report-created";
export { deleteUserData } from "./delete-user-data";
