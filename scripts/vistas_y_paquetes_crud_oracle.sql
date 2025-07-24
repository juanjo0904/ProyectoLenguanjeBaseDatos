/* =============================================================
   ===============          V I S T A S          ===============
   ============================================================= */

-- 1) Clientes con su última zona entregada (usando tabla Entrega)
CREATE OR REPLACE VIEW v_clientes_zona AS
SELECT  c.id_cliente,
        c.nombre_cliente,
        c.tipo_cliente,
        z.id_zona,
        z.nombre_zona,
        MAX(e.fecha_entrega) AS ultima_entrega
FROM Cliente c
LEFT JOIN Entrega e   ON e.id_cliente = c.id_cliente
LEFT JOIN Zona_Entrega z ON z.id_zona = e.id_zona
GROUP BY c.id_cliente, c.nombre_cliente, c.tipo_cliente, z.id_zona, z.nombre_zona;
/

-- 2) Detalle de entregas (cliente, zona, fecha)
CREATE OR REPLACE VIEW v_entregas_detalle AS
SELECT  e.id_entrega,
        e.fecha_entrega,
        c.id_cliente,
        c.nombre_cliente,
        z.id_zona,
        z.nombre_zona
FROM Entrega e
JOIN Cliente c       ON c.id_cliente = e.id_cliente
JOIN Zona_Entrega z  ON z.id_zona = e.id_zona;
/

-- 3) Productos con su categoría
CREATE OR REPLACE VIEW v_productos_categoria AS
SELECT  p.id_producto,
        p.nombre_producto,
        p.descripcion,
        c.id_categoria,
        c.nombre_categoria
FROM Producto p
JOIN Categoria c ON c.id_categoria = p.id_categoria;
/

-- 4) Inventario actual con nombre del producto
CREATE OR REPLACE VIEW v_inventario_actual AS
SELECT  i.id_producto,
        p.nombre_producto,
        i.cantidad,
        i.fecha_actualizacion
FROM Inventario i
JOIN Producto p ON p.id_producto = i.id_producto;
/

-- 5) Historial de inventario (últimos movimientos por producto)
CREATE OR REPLACE VIEW v_historial_inventario AS
SELECT  h.id_historial,
        h.id_producto,
        p.nombre_producto,
        h.cantidad,
        h.fecha_modificacion
FROM Historial_Inventario h
JOIN Producto p ON p.id_producto = h.id_producto;
/

-- 6) Precios actuales por tipo de cliente
CREATE OR REPLACE VIEW v_precios_actuales AS
SELECT  pr.id_precio,
        pr.id_producto,
        p.nombre_producto,
        pr.tipo_cliente,
        pr.precio_unitario
FROM Precio pr
JOIN Producto p ON p.id_producto = pr.id_producto;
/

-- 7) Historial de precios por producto
CREATE OR REPLACE VIEW v_historial_precios AS
SELECT  hp.id_historial,
        hp.id_producto,
        p.nombre_producto,
        hp.tipo_cliente,
        hp.precio_unitario,
        hp.fecha_cambio
FROM Historial_Precio hp
JOIN Producto p ON p.id_producto = hp.id_producto;
/

-- 8) Usuarios con su rol
CREATE OR REPLACE VIEW v_usuarios_roles AS
SELECT  u.id_usuario,
        u.nombre_usuario,
        r.id_rol,
        r.nombre_rol
FROM Usuario u
JOIN Rol r ON r.id_rol = u.id_rol;
/

-- 9) Resumen de entregas por cliente (conteo)
CREATE OR REPLACE VIEW v_total_entregas_cliente AS
SELECT  c.id_cliente,
        c.nombre_cliente,
        COUNT(e.id_entrega) AS total_entregas
FROM Cliente c
LEFT JOIN Entrega e ON e.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre_cliente;
/

-- 10) Combos activos hoy
CREATE OR REPLACE VIEW v_combos_activos_hoy AS
SELECT  id_combo,
        nombre,
        descripcion,
        fecha_inicio,
        fecha_fin
FROM COMBO
WHERE SYSDATE BETWEEN fecha_inicio AND fecha_fin;
/

/* =============================================================
   ============          P A Q U E T E S          ==============
   Cada paquete incluye: INS, UPD, DEL, GET_BY_ID, LIST_ALL
   (SYS_REFCURSOR para devolver datos)
   ============================================================= */

-- Utilidad: tipo de cursor común
CREATE OR REPLACE PACKAGE tipos_comunes AS
  TYPE t_cursor IS REF CURSOR;
END tipos_comunes;
/

/* ------------------- 1. PCK_ROL ------------------- */
CREATE OR REPLACE PACKAGE pck_rol AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2);
  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2);
  PROCEDURE del(p_id IN NUMBER);
  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor);
  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor);
END pck_rol;
/

CREATE OR REPLACE PACKAGE BODY pck_rol AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2) IS
  BEGIN
    INSERT INTO Rol(id_rol, nombre_rol) VALUES (p_id, p_nombre);
  END;

  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2) IS
  BEGIN
    UPDATE Rol SET nombre_rol = p_nombre WHERE id_rol = p_id;
  END;

  PROCEDURE del(p_id IN NUMBER) IS
  BEGIN
    DELETE FROM Rol WHERE id_rol = p_id;
  END;

  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Rol WHERE id_rol = p_id;
  END;

  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Rol;
  END;
END pck_rol;
/

/* ------------------- 2. PCK_USUARIO ------------------- */
CREATE OR REPLACE PACKAGE pck_usuario AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2, p_pass IN VARCHAR2, p_rol IN NUMBER);
  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2, p_pass IN VARCHAR2, p_rol IN NUMBER);
  PROCEDURE del(p_id IN NUMBER);
  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor);
  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor);
END pck_usuario;
/

CREATE OR REPLACE PACKAGE BODY pck_usuario AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2, p_pass IN VARCHAR2, p_rol IN NUMBER) IS
  BEGIN
    INSERT INTO Usuario(id_usuario, nombre_usuario, contrasena, id_rol)
    VALUES (p_id, p_nombre, p_pass, p_rol);
  END;

  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2, p_pass IN VARCHAR2, p_rol IN NUMBER) IS
  BEGIN
    UPDATE Usuario
       SET nombre_usuario = p_nombre,
           contrasena     = p_pass,
           id_rol         = p_rol
     WHERE id_usuario     = p_id;
  END;

  PROCEDURE del(p_id IN NUMBER) IS
  BEGIN
    DELETE FROM Usuario WHERE id_usuario = p_id;
  END;

  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Usuario WHERE id_usuario = p_id;
  END;

  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Usuario;
  END;
END pck_usuario;
/

/* ------------------- 3. PCK_CLIENTE ------------------- */
CREATE OR REPLACE PACKAGE pck_cliente AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2, p_tipo IN VARCHAR2, p_zona IN VARCHAR2);
  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2, p_tipo IN VARCHAR2, p_zona IN VARCHAR2);
  PROCEDURE del(p_id IN NUMBER);
  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor);
  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor);
END pck_cliente;
/

CREATE OR REPLACE PACKAGE BODY pck_cliente AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2, p_tipo IN VARCHAR2, p_zona IN VARCHAR2) IS
  BEGIN
    INSERT INTO Cliente(id_cliente, nombre_cliente, tipo_cliente, zona_entrega)
    VALUES (p_id, p_nombre, p_tipo, p_zona);
  END;

  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2, p_tipo IN VARCHAR2, p_zona IN VARCHAR2) IS
  BEGIN
    UPDATE Cliente
       SET nombre_cliente = p_nombre,
           tipo_cliente   = p_tipo,
           zona_entrega   = p_zona
     WHERE id_cliente     = p_id;
  END;

  PROCEDURE del(p_id IN NUMBER) IS
  BEGIN
    DELETE FROM Cliente WHERE id_cliente = p_id;
  END;

  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Cliente WHERE id_cliente = p_id;
  END;

  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Cliente;
  END;
END pck_cliente;
/

/* ------------------- 4. PCK_ZONA_ENTREGA ------------------- */
CREATE OR REPLACE PACKAGE pck_zona_entrega AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2);
  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2);
  PROCEDURE del(p_id IN NUMBER);
  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor);
  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor);
END pck_zona_entrega;
/

CREATE OR REPLACE PACKAGE BODY pck_zona_entrega AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2) IS
  BEGIN
    INSERT INTO Zona_Entrega(id_zona, nombre_zona) VALUES (p_id, p_nombre);
  END;

  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2) IS
  BEGIN
    UPDATE Zona_Entrega SET nombre_zona = p_nombre WHERE id_zona = p_id;
  END;

  PROCEDURE del(p_id IN NUMBER) IS
  BEGIN
    DELETE FROM Zona_Entrega WHERE id_zona = p_id;
  END;

  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Zona_Entrega WHERE id_zona = p_id;
  END;

  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Zona_Entrega;
  END;
END pck_zona_entrega;
/

/* ------------------- 5. PCK_ENTREGA ------------------- */
CREATE OR REPLACE PACKAGE pck_entrega AS
  PROCEDURE ins(p_id IN NUMBER, p_cliente IN NUMBER, p_zona IN NUMBER, p_fecha IN DATE);
  PROCEDURE upd(p_id IN NUMBER, p_cliente IN NUMBER, p_zona IN NUMBER, p_fecha IN DATE);
  PROCEDURE del(p_id IN NUMBER);
  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor);
  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor);
END pck_entrega;
/

CREATE OR REPLACE PACKAGE BODY pck_entrega AS
  PROCEDURE ins(p_id IN NUMBER, p_cliente IN NUMBER, p_zona IN NUMBER, p_fecha IN DATE) IS
  BEGIN
    INSERT INTO Entrega(id_entrega, id_cliente, id_zona, fecha_entrega)
    VALUES (p_id, p_cliente, p_zona, p_fecha);
  END;

  PROCEDURE upd(p_id IN NUMBER, p_cliente IN NUMBER, p_zona IN NUMBER, p_fecha IN DATE) IS
  BEGIN
    UPDATE Entrega
       SET id_cliente    = p_cliente,
           id_zona       = p_zona,
           fecha_entrega = p_fecha
     WHERE id_entrega    = p_id;
  END;

  PROCEDURE del(p_id IN NUMBER) IS
  BEGIN
    DELETE FROM Entrega WHERE id_entrega = p_id;
  END;

  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Entrega WHERE id_entrega = p_id;
  END;

  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Entrega;
  END;
END pck_entrega;
/

/* ------------------- 6. PCK_CATEGORIA ------------------- */
CREATE OR REPLACE PACKAGE pck_categoria AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2);
  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2);
  PROCEDURE del(p_id IN NUMBER);
  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor);
  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor);
END pck_categoria;
/

CREATE OR REPLACE PACKAGE BODY pck_categoria AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2) IS
  BEGIN
    INSERT INTO Categoria(id_categoria, nombre_categoria) VALUES (p_id, p_nombre);
  END;

  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2) IS
  BEGIN
    UPDATE Categoria SET nombre_categoria = p_nombre WHERE id_categoria = p_id;
  END;

  PROCEDURE del(p_id IN NUMBER) IS
  BEGIN
    DELETE FROM Categoria WHERE id_categoria = p_id;
  END;

  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Categoria WHERE id_categoria = p_id;
  END;

  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Categoria;
  END;
END pck_categoria;
/

/* ------------------- 7. PCK_PRODUCTO ------------------- */
CREATE OR REPLACE PACKAGE pck_producto AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2, p_desc IN VARCHAR2, p_cat IN NUMBER);
  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2, p_desc IN VARCHAR2, p_cat IN NUMBER);
  PROCEDURE del(p_id IN NUMBER);
  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor);
  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor);
END pck_producto;
/

CREATE OR REPLACE PACKAGE BODY pck_producto AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2, p_desc IN VARCHAR2, p_cat IN NUMBER) IS
  BEGIN
    INSERT INTO Producto(id_producto, nombre_producto, descripcion, id_categoria)
    VALUES (p_id, p_nombre, p_desc, p_cat);
  END;

  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2, p_desc IN VARCHAR2, p_cat IN NUMBER) IS
  BEGIN
    UPDATE Producto
       SET nombre_producto = p_nombre,
           descripcion     = p_desc,
           id_categoria    = p_cat
     WHERE id_producto     = p_id;
  END;

  PROCEDURE del(p_id IN NUMBER) IS
  BEGIN
    DELETE FROM Producto WHERE id_producto = p_id;
  END;

  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Producto WHERE id_producto = p_id;
  END;

  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Producto;
  END;
END pck_producto;
/

/* ------------------- 8. PCK_INVENTARIO ------------------- */
CREATE OR REPLACE PACKAGE pck_inventario AS
  PROCEDURE ins(p_id_producto IN NUMBER, p_cantidad IN NUMBER, p_fecha IN DATE);
  PROCEDURE upd(p_id_producto IN NUMBER, p_cantidad IN NUMBER, p_fecha IN DATE);
  PROCEDURE del(p_id_producto IN NUMBER);
  PROCEDURE get_by_id(p_id_producto IN NUMBER, p_rc OUT tipos_comunes.t_cursor);
  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor);
END pck_inventario;
/

CREATE OR REPLACE PACKAGE BODY pck_inventario AS
  PROCEDURE ins(p_id_producto IN NUMBER, p_cantidad IN NUMBER, p_fecha IN DATE) IS
  BEGIN
    INSERT INTO Inventario(id_producto, cantidad, fecha_actualizacion)
    VALUES (p_id_producto, p_cantidad, p_fecha);
  END;

  PROCEDURE upd(p_id_producto IN NUMBER, p_cantidad IN NUMBER, p_fecha IN DATE) IS
  BEGIN
    UPDATE Inventario
       SET cantidad = p_cantidad,
           fecha_actualizacion = p_fecha
     WHERE id_producto = p_id_producto;
  END;

  PROCEDURE del(p_id_producto IN NUMBER) IS
  BEGIN
    DELETE FROM Inventario WHERE id_producto = p_id_producto;
  END;

  PROCEDURE get_by_id(p_id_producto IN NUMBER, p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Inventario WHERE id_producto = p_id_producto;
  END;

  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Inventario;
  END;
END pck_inventario;
/

/* ------------------- 9. PCK_PRECIO ------------------- */
CREATE OR REPLACE PACKAGE pck_precio AS
  PROCEDURE ins(p_id IN NUMBER, p_producto IN NUMBER, p_tipo IN VARCHAR2, p_precio IN NUMBER);
  PROCEDURE upd(p_id IN NUMBER, p_precio IN NUMBER);
  PROCEDURE del(p_id IN NUMBER);
  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor);
  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor);
END pck_precio;
/

CREATE OR REPLACE PACKAGE BODY pck_precio AS
  PROCEDURE ins(p_id IN NUMBER, p_producto IN NUMBER, p_tipo IN VARCHAR2, p_precio IN NUMBER) IS
  BEGIN
    INSERT INTO Precio(id_precio, id_producto, tipo_cliente, precio_unitario)
    VALUES (p_id, p_producto, p_tipo, p_precio);
  END;

  PROCEDURE upd(p_id IN NUMBER, p_precio IN NUMBER) IS
  BEGIN
    UPDATE Precio SET precio_unitario = p_precio WHERE id_precio = p_id;
  END;

  PROCEDURE del(p_id IN NUMBER) IS
  BEGIN
    DELETE FROM Precio WHERE id_precio = p_id;
  END;

  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Precio WHERE id_precio = p_id;
  END;

  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM Precio;
  END;
END pck_precio;
/

/* ------------------- 10. PCK_COMBO ------------------- */
CREATE OR REPLACE PACKAGE pck_combo AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2, p_desc IN CLOB, p_ini IN DATE, p_fin IN DATE);
  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2, p_desc IN CLOB, p_ini IN DATE, p_fin IN DATE);
  PROCEDURE del(p_id IN NUMBER);
  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor);
  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor);
END pck_combo;
/

CREATE OR REPLACE PACKAGE BODY pck_combo AS
  PROCEDURE ins(p_id IN NUMBER, p_nombre IN VARCHAR2, p_desc IN CLOB, p_ini IN DATE, p_fin IN DATE) IS
  BEGIN
    INSERT INTO COMBO(id_combo, nombre, descripcion, fecha_inicio, fecha_fin)
    VALUES (p_id, p_nombre, p_desc, p_ini, p_fin);
  END;

  PROCEDURE upd(p_id IN NUMBER, p_nombre IN VARCHAR2, p_desc IN CLOB, p_ini IN DATE, p_fin IN DATE) IS
  BEGIN
    UPDATE COMBO
       SET nombre        = p_nombre,
           descripcion   = p_desc,
           fecha_inicio  = p_ini,
           fecha_fin     = p_fin
     WHERE id_combo      = p_id;
  END;

  PROCEDURE del(p_id IN NUMBER) IS
  BEGIN
    DELETE FROM COMBO WHERE id_combo = p_id;
  END;

  PROCEDURE get_by_id(p_id IN NUMBER, p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM COMBO WHERE id_combo = p_id;
  END;

  PROCEDURE list_all(p_rc OUT tipos_comunes.t_cursor) IS
  BEGIN
    OPEN p_rc FOR SELECT * FROM COMBO;
  END;
END pck_combo;
/
