const express = require("express");
const app=express();
app.use(express.json());
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

app.post("/employees",(req,res)=>{
    console.log(req.body.name)
    res.send(req.body);
})

app.listen(PORT,()=>{
   console.log(`server is running on port ${PORT}`);
});
