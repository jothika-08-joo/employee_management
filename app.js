const express = require("express");
const app=express();
const employeeRoutes = require("./routes/employeeRoutes");
app.use(express.json());
app.use("/employees", employeeRoutes);
const PORT=3000;

app.get("/",(req,res) => {
   res.send("employess management api is running ")
});

app.listen(PORT,()=>{
   console.log(`server is running on port ${PORT}`);
});
