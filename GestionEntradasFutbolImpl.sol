contract GestionEntradasFutbolImpl is GestionEntradasFutbol {
    struct Entrada {
        uint partidoId;
        address propietario;
        bool valida;
    }

    struct Partido {
        uint id;
        uint precio;
        uint entradasDisponibles;
        uint totalEntradas;
    }

    address public administrador;
    mapping(uint => Partido) public partidos; // Mapea ID de partido a sus datos
    mapping(uint => Entrada) public entradas; // Mapea ID de entrada a sus datos
    uint public nextEntradaId; // ID incremental para las entradas

    modifier soloAdministrador() {
        require(
            msg.sender == administrador,
            "Acceso denegado: Solo el administrador puede realizar esta acción"
        );
        _;
    }

    modifier soloPropietario(uint entradaId) {
        require(
            entradas[entradaId].propietario == msg.sender,
            "No eres el propietario de esta entrada"
        );
        _;
    }

    constructor() {
        administrador = msg.sender; // El despliegue lo realiza el administrador
    }

    // Agregar un nuevo partido (Solo administrador)
    function agregarPartido(
        uint partidoId,
        uint precio,
        uint totalEntradas
    ) external soloAdministrador {
        require(partidos[partidoId].id == 0, "El partido ya existe");
        partidos[partidoId] = Partido(
            partidoId,
            precio,
            totalEntradas,
            totalEntradas
        );
    }

    // Comprar una entrada
    function comprarEntrada(
        uint partidoId,
        uint cantidad
    ) external payable override returns (bool) {
        Partido storage partido = partidos[partidoId];
        require(partido.id != 0, "El partido no existe");
        require(
            partido.entradasDisponibles >= cantidad,
            "No hay suficientes entradas disponibles"
        );
        require(msg.value >= partido.precio * cantidad, "Fondos insuficientes");

        for (uint i = 0; i < cantidad; i++) {
            entradas[nextEntradaId] = Entrada(partidoId, msg.sender, true);
            nextEntradaId++;
        }

        partido.entradasDisponibles -= cantidad;
        return true;
    }

    // Revender una entrada
    function revenderEntrada(
        uint entradaId,
        uint precio
    ) external override soloPropietario(entradaId) returns (bool) {
        require(entradas[entradaId].valida, "La entrada no es válida");
        entradas[entradaId].valida = false; // Marcamos la entrada como revendida
        return true;
    }

    // Transferir una entrada
    function transferirEntrada(
        uint entradaId,
        address nuevoPropietario
    ) external override soloPropietario(entradaId) returns (bool) {
        require(entradas[entradaId].valida, "La entrada no es válida");
        entradas[entradaId].propietario = nuevoPropietario;
        return true;
    }

    // Verificar si una entrada es válida
    function verificarEntrada(
        uint entradaId
    ) external view override returns (bool valida) {
        return entradas[entradaId].valida;
    }

    // Consultar la disponibilidad de entradas para un partido
    function consultarDisponibilidad(
        uint partidoId
    ) external view override returns (uint disponibles) {
        return partidos[partidoId].entradasDisponibles;
    }

    // Retirar fondos acumulados por ventas de entradas (Solo administrador)
    function retirarFondos() external soloAdministrador {
        payable(administrador).transfer(address(this).balance);
    }
}
