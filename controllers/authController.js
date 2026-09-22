const db = require('../config/db');
const bcrypt = require('bcrypt');

exports.register = async (req, res) => {
  try {

    const { nombre, email, password } = req.body;

    if (!nombre || !email || !password) {
      return res.status(400).json({
        msg: 'Campos incompletos'
      });
    }

    const hash = await bcrypt.hash(password, 10);


    await db.query(
      'INSERT INTO users (nombre, email, password, rol) VALUES (?,?,?,?)',
      [nombre, email, hash, 'cliente']
    );


    res.sendStatus(201);


  } catch (err) {

    console.error('Error registro:', err);

    res.status(500).json({
      msg: 'Error al registrar'
    });

  }
};



exports.login = async (req, res) => {

  try {

    const { email, password } = req.body;


    const [result] = await db.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );


    if (result.length === 0) {

      return res.status(401).json({
        msg: 'Usuario no existe'
      });

    }


    const user = result[0];


    const ok = await bcrypt.compare(
      password,
      user.password
    );


    if (!ok) {

      return res.status(401).json({
        msg: 'Credenciales incorrectas'
      });

    }


    req.session.user = {

      id: user.id,
      rol: user.rol,
      nombre: user.nombre

    };


    if (user.rol === 'admin') {

      return res.redirect('/html/admin.html');

    } 

    else if (user.rol === 'vendedor') {

      return res.redirect('/html/vendedor.html');

    } 

    else {

      return res.redirect('/html/cliente.html');

    }


  } catch(err){

    console.error('Error login:', err);

    res.sendStatus(500);

  }

};