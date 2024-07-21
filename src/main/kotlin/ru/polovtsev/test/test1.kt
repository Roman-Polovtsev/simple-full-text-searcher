package ru.polovtsev.test

import java.io.DataOutputStream
import java.net.Socket
import java.util.*

interface Vehicle {

    fun model(): String

    fun color(): String

    fun manufacturedAt(): Date

    fun speedLimitKmPH(): Int

    fun powerKW(): Int

    companion object {

        data class DiagnosticError(val code: Int, val description: String)
    }
}

interface VehicleRemoteControl {

    fun ignitionOn(): Boolean

    fun ignitionOff(): Boolean

    fun selfCheck(): Set<Vehicle.Companion.DiagnosticError>
}

class CANVehicleRemoteControl(private val vehicle: Vehicle) : VehicleRemoteControl {

    private val socket: Socket = TODO()

    private val stream = socket.getOutputStream()

    private val commandsMap = mapOf<String, Map<String, ByteArray>>(
        Pair(
            "vw.polo",
            mapOf(
                Pair("ignitionOn", "XH2451".toByteArray()),
                Pair("ignitionOff", "XH2450".toByteArray()),
                Pair("selfCheck", "WK1499".toByteArray())
            )
        )
    )

    override fun ignitionOn(): Boolean {
        val commandToSend = commandsMap.get(vehicle.model())!!.get("ignitionOn")!!
        stream.write(commandToSend)
        TODO("... analyze the state")
    }

    override fun ignitionOff(): Boolean {
        val commandToSend = commandsMap.get(vehicle.model())!!.get("ignitionOff")!!
        stream.write(commandToSend)
        TODO("... analyze the state")
    }

    override fun selfCheck(): Set<Vehicle.Companion.DiagnosticError> {
        val commandToSend = commandsMap.get(vehicle.model())!!.get("selfCheck")!!
        stream.write(commandToSend)
        val message = socket.getInputStream().readAllBytes()
        TODO("... parse message")
    }
}