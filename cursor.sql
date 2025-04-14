-- Creamos una nueva tabla para guardar el resultado
CREATE TABLE Actividad_Reciente_Simple (
    NombreUsuario VARCHAR(45),
    Actividad VARCHAR(50),
    Fecha_inicio DATETIME
);

-- Usamos delimitador para el procedimiento
DELIMITER $$

CREATE PROCEDURE ObtenerActividadRecienteSimple()
BEGIN
    DECLARE done INT DEFAULT 0;

    -- Variables para usuario
    DECLARE v_IdUsuario INT;
    DECLARE v_NombreUsuario VARCHAR(45);

    -- Variables para actividad más reciente
    DECLARE v_Actividad VARCHAR(50);
    DECLARE v_FechaInicio DATETIME;

    -- Cursor para recorrer los usuarios
    DECLARE cur_usuarios CURSOR FOR
        SELECT IdPersonas, Nombre FROM Personas;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur_usuarios;

    usuarios_loop: LOOP
        FETCH cur_usuarios INTO v_IdUsuario, v_NombreUsuario;
        IF done THEN
            LEAVE usuarios_loop;
        END IF;

        -- Limpiar variables
        SET v_Actividad = NULL;
        SET v_FechaInicio = NULL;

        -- Obtener la actividad más reciente
        SELECT a.Nombre, a.Fecha_inicio
        INTO v_Actividad, v_FechaInicio
        FROM Planificador pl
        JOIN Actividades a ON pl.IdActividad = a.IdActividades
        WHERE pl.IdUsuario = v_IdUsuario
        ORDER BY a.Fecha_inicio DESC
        LIMIT 1;

        -- Insertar resultado en tabla
        INSERT INTO Actividad_Reciente_Simple (
            NombreUsuario, Actividad, Fecha_inicio
        ) VALUES (
            v_NombreUsuario, v_Actividad, v_FechaInicio
        );

    END LOOP;

    CLOSE cur_usuarios;
END$$

DELIMITER ;

-- Ejecutar el procedimiento
CALL ObtenerActividadRecienteSimple();

-- Ver resultado
SELECT * FROM Actividad_Reciente_Simple;
