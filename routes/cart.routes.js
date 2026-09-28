const express = require('express');
const router = express.Router();
const db = require('../config/db');

// ============================================
// MIDDLEWARE: VERIFICAR QUE EL USUARIO ESTÉ LOGUEADO
// ============================================
const isAuth = (req, res, next) => {
    if (!req.session.user) {
        return res.status(401).json({
            error: 'No autorizado'
        });
    }

    next();
};


// ============================================
// 1. VER CARRITO
// ============================================
router.get('/', isAuth, async (req, res) => {

    try {

        const cart = req.session.cart || [];

        // Si está vacío, regresar directamente []
        if (cart.length === 0) {
            return res.json([]);
        }

        // Obtener los IDs de todos los productos del carrito
        const ids = cart.map(item => Number(item.productId));

        // Crear ?,?,? dependiendo de la cantidad de productos
        const placeholders = ids.map(() => '?').join(',');

        // Obtener las imágenes actuales directamente desde la BD
        const [productos] = await db.query(
            `SELECT id, imagen
             FROM products
             WHERE id IN (${placeholders})`,
            ids
        );

        // Crear un mapa:
        // ID producto -> imagen
        const imagenes = new Map();

        productos.forEach(producto => {
            imagenes.set(
                Number(producto.id),
                producto.imagen
            );
        });

        // Agregar la imagen a cada producto del carrito
        const cartCompleto = cart.map(item => ({
            ...item,
            imagen:
                imagenes.get(Number(item.productId))
                || item.imagen
                || null
        }));

        // Actualizar también la sesión
        req.session.cart = cartCompleto;

        res.json(cartCompleto);

    } catch (error) {

        console.error('Error obteniendo carrito:', error);

        res.status(500).json({
            error: 'Error obteniendo carrito'
        });

    }

});


// ============================================
// 2. AGREGAR PRODUCTO AL CARRITO
// ============================================
router.post('/add', isAuth, async (req, res) => {

    try {

        const { productId, cantidad } = req.body;

        // Convertir los valores explícitamente a número
        const idProducto = Number(productId);
        const cantidadProducto = Number(cantidad) || 1;

        if (!req.session.cart) {
            req.session.cart = [];
        }

        // IMPORTANTE:
        // Ahora también recuperamos "imagen"
        const [result] = await db.query(
            `SELECT
                id,
                nombre,
                precio,
                imagen
             FROM products
             WHERE id = ?`,
            [idProducto]
        );

        if (result.length === 0) {
            return res.status(404).json({
                error: 'Producto no existe'
            });
        }

        const prod = result[0];

        // Buscar si el producto ya estaba en el carrito
        const item = req.session.cart.find(
            p => Number(p.productId) === Number(prod.id)
        );

        if (item) {

            // Si ya estaba, aumentar cantidad
            item.cantidad += cantidadProducto;

            // Actualizar también la imagen
            item.imagen = prod.imagen;

        } else {

            // Si no estaba, agregarlo
            req.session.cart.push({
                productId: prod.id,
                nombre: prod.nombre,
                precio: Number(prod.precio),
                cantidad: cantidadProducto,
                imagen: prod.imagen
            });

        }

        // Guardar explícitamente la sesión
        req.session.save(err => {

            if (err) {

                console.error(
                    'Error guardando carrito en sesión:',
                    err
                );

                return res.status(500).json({
                    error: 'Error guardando carrito'
                });

            }

            res.json(req.session.cart);

        });

    } catch (error) {

        console.error('Error agregando producto:', error);

        res.status(500).json({
            error: 'Error agregando producto'
        });

    }

});


// ============================================
// 3. ELIMINAR PRODUCTO DEL CARRITO
// ============================================
router.post('/remove', isAuth, (req, res) => {

    const { productId } = req.body;

    // Convertimos a número para evitar problemas entre:
    // "10" !== 10
    const idProducto = Number(productId);

    req.session.cart = (req.session.cart || []).filter(
        producto =>
            Number(producto.productId) !== idProducto
    );

    // Guardamos explícitamente la sesión
    req.session.save(err => {

        if (err) {

            console.error(
                'Error guardando carrito después de eliminar:',
                err
            );

            return res.status(500).json({
                error: 'Error eliminando producto'
            });

        }

        res.json({
            mensaje: 'Producto eliminado',
            cart: req.session.cart
        });

    });

});


module.exports = router;