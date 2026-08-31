const express = require("express");
const app=express();
const PORT=3000;
app.get("/",(req,res) => {
   res.send("employess management api is running ")
});

app.get("/hello",(req,res)=>{
    res.send("hello from jothika")
});

app.get("/status",(req,res)=>{
    res.json({status:"running"})
})


app.listen(PORT,()=>{
   console.log(`server is running on port ${PORT}`);
});
