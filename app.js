const express = require("express");
const cors = require("cors");
const app=express();
const employeeRoutes = require("./routes/employeeRoutes");
app.use(cors());
app.use(express.json());
app.use("/employees", employeeRoutes);
const PORT=3000;

app.get("/",(req,res) => {
   res.send("employess management api is running ")
});

app.listen(PORT,()=>{
   console.log(`server is running on port ${PORT}`);
});
