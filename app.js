const pool = require("./db");
const express = require("express");
const app=express();
app.use(express.json());
const PORT=3000;
app.get("/employees",async (req,res)=>{
    try{
        const result=await pool.query("select * from employees");
        res.json(result.rows);
    }catch(error){
        console.log(error);
        res.status(500).json({
            message:"internal server error",
        });
    }
});
app.get("/employees/:id",async(req,res)=>{
    try{
        const id=req.params.id;
        const result=await pool.query("select * from employees where id=$1",[id]);
        if (result.rows.length===0){
            res.status(404).json({message:"employee not found"})
        }else{
            res.json(result.rows);
        }
        
    }catch(error){
        console.log(error);
        res.status(500).json({message:"database error"});
    }
});
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
