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
app.post("/employees",async(req,res)=>{
    try{
        const {name,email,department,salary}=req.body
        
            if (!name || !email || !department || !salary){
                return res.status(400).json({
                    message:"all fields are required"
                });
            }
            const result=await pool.query(`insert into employees (name,email,department,salary) values($1,$2,$3,$4)RETURNING *`,[name,email,department,salary]);
            return res.status(201).json({
                message:"employee created successfully",
                employee:result.rows[0]
            });
        }catch(error){
            console.log(error);
            res.status(500).json({
                message:"database error"
            })
        }

});
app.put("/employees/:id",async(req,res)=>{
    try{
        const id=req.params.id;
        const{name,email,department,salary}=req.body;
        if (!name || !email || !department || !salary){
            return res.status(400).json({
                message:"all fields are required"
            });  
        }
        const result=await pool.query("update employees set name=$1,email=$2,department=$3,salary=$4 where id=$5 RETURNING *",[name,email,department,salary,id] );
        if(result.rows.length===0){
            return res.status(404).json({
                message:"employee not found"
            });
        }
        res.json({
            message:"employee updated successfully",
            employee:result.rows[0],
        });
    }catch(error){
        console.log(error);
        res.status(500).json({
            message:"database error",
        });
    }
});
app.delete("/employees/:id",async(req,res)=>{
   try{
     const id=req.params.id;
     const result=await pool.query("delete from employees where id=$1 RETURNING* ",[id]);
     if (result.rows.length===0){
        return res.status(404).json({
            message:"employee not found"
        });

     }
     res.status(200).json({
        message:"employee deleted successfully",
        employee:result.rows[0]
     })
   }catch(error){
    console.log(error);
    res.status(500).json({
        message:"database error"
    })
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
