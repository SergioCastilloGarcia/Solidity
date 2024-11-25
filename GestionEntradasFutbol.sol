// Interfaz para la gestión de entradas de fútbol
interface GestionEntradasFutbol {
    // Función para comprar una entrada
    function comprarEntrada(uint partidoId, uint cantidad) external payable returns (bool);
    
    // Función para revender una entrada
    function revenderEntrada(uint entradaId, uint precio) external returns (bool);
    
    // Función para transferir una entrada a otro usuario
    function transferirEntrada(uint entradaId, address nuevoPropietario) external returns (bool);
    
    // Función para verificar si una entrada es válida
    function verificarEntrada(uint entradaId) external view returns (bool valida);
    
    // Función para consultar el estado de disponibilidad de entradas para un partido
    function consultarDisponibilidad(uint partidoId) external view returns (uint disponibles);
}
