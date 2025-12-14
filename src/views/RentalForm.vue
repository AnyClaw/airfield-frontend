<script setup>
import Header from '@/components/Header.vue';
import Form from '@/components/Form.vue';
import { onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';

const route = useRoute()
const router = useRouter()

const plane = ref('')
const profile = ref('')

const arrivalICAO = ref()
const departureICAO = ref()
const arrivalAirport = ref(null)
const departureAirport = ref(null)

const rentalData = ref({
    userId: 0,
    planeId: 0,
    arrivalAirportId: '',
    departureAirportId: '',
    flightRoute: [],
    distance: 0,
    refuel: 0,
    maintenance: false,
    maintenanceCost: 0
})

const isArrivalIcaoValid = ref(false)
const isDepartureIcaoValid = ref(false)
const isRefuel = ref(false)
const isLoading = ref(true)

async function getPlane() {
    isLoading.value = true

    const planeId = route.params.id

    if (!planeId) {
        router.push({name: 'Planes'})
        return
    }

    try {
        const response = await axios.get(`http://localhost:8080/planes/${planeId}`)
        plane.value = response.data

        const maintenanceCost = {
            "EXCELLENT": 0,
            "GOOD": 1,
            "FAIR": 2,
            "POOR": 3
        }

        rentalData.value.maintenanceCost = plane.value.maintenanceCost * maintenanceCost[plane.value.condition]
        rentalData.value.planeId = plane.value.id
    } catch (error) {
        alert('error')
        console.log(error)
    }

    isLoading.value = false
}

async function checkToken() {
    isLoading.value = true

    const token = localStorage.getItem('authToken')

    if (!token) {
        router.push({name: 'Login'})
        return
    }   

    try {
        const response = await axios.get('http://localhost:8080/pilot/profile', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })

        profile.value = response.data
        rentalData.value.userId = profile.value.user.id
    } catch(error) {
        if (error.response?.status === 401) {
            localStorage.removeItem('authToken');
            router.push({name: 'Login'});
        }
        else console.log(error)
    }
}

async function getArrivalAirport() {
    if (arrivalAirport.value != null && arrivalICAO.value === arrivalAirport.value.icao) return
    console.log("called")

    try {
        const response = await axios.get(`http://localhost:8080/airport/${arrivalICAO.value}`)
        isArrivalIcaoValid.value = true
        arrivalAirport.value = response.data
        rentalData.value.arrivalAirportId = arrivalAirport.value.id
    } catch(error) {
        if (error.response?.status === 404) {
            isArrivalIcaoValid.value = false
            arrivalAirport.value = null
        }
        else {
            alert("error")
            console.log(error)
        }
    }
}

async function getDepartureAirport() {
    if (departureAirport.value != null && departureICAO.value === departureAirport.value.icao) return

    try {
        const response = await axios.get(`http://localhost:8080/airport/${departureICAO.value}`)
        isDepartureIcaoValid.value = true
        departureAirport.value = response.data
        rentalData.value.departureAirportId = departureAirport.value.id
    } catch(error) {
        if (error.response?.status === 404) {
            isDepartureIcaoValid.value = false
            departureAirport.value = null
        }
        else {
            alert("error")
            console.log(error)
        }
    }

    rentalData.value.flightRoute = []
}

async function buildRoute() {
    try {
        const response = await axios.get(`http://localhost:8080/flight/build?arrivalIcao=${arrivalICAO.value}&departureIcao=${departureICAO.value}`)
        rentalData.value.flightRoute = response.data.route
        rentalData.value.distance = response.data.distance
    }
    catch (error) {
        alert("error")
        console.log(error)
    }
}

function getFlightRoute() {
    const flightRoute = rentalData.value.flightRoute

    if (flightRoute.length == 0) return ''

    return flightRoute[0].fromWaypoint.name + ", " + flightRoute.map(w => w.toWaypoint.name).join(", ")
}

function refuelValidate() {
    const refuel = Number(rentalData.value.refuel)
    const totalFuel = plane.value.fuel

    if (isNaN(refuel)) {
        return false
    }

    return refuel >= 0 && refuel + totalFuel <= plane.value.tankCapacity
}

function refuelCost(){
    return 100 * rentalData.value.refuel
}

async function rent() {
    try {
        const token = localStorage.getItem('authToken')
        const response = await axios.post('http://localhost:8080/rent', rentalData.value, {
            headers: {
                'Authorization': `Bearer ${token}`
            },
        })
        console.log(response.data)
    }
    catch(error) {
        alert('err')
        console.log(error)
    }
}

onMounted(() => {
    getPlane()
    checkToken()
})
</script>

<template>
    <Header/>
    <Form>
        <h1>Форма для аренды самолёта</h1>
        <section v-if="!isLoading && profile != null" class="content">
            <div class="info-label">
                Самолёт: <label style="cursor: pointer;">{{ plane.name }}</label>
            </div>
            <div class="info-label">Состояние: {{ plane.condition }}</div>

            <div class="param-input-button">
                <div>ICAO аэропорта вылета: </div>
                <input :class="{'error-input': !isArrivalIcaoValid}" type="text" v-model="arrivalICAO">
                <button @click="getArrivalAirport">Найти аэропорт</button>
            </div>
            <div class="param-input-button">
                <div>ICAO аэропорта прилёта: </div>
                <input :class="{'error-input': !isDepartureIcaoValid}" type="text" v-model="departureICAO">
                <button @click="getDepartureAirport">Найти аэропорт</button>
            </div>

            <div class="param-input" v-if="rentalData.flightRoute.length == 0">
                <button @click="buildRoute" :disabled="!(isArrivalIcaoValid && isDepartureIcaoValid)">Построить маршрут</button>
            </div>
            <div v-else>
                <div class="param-input">Маршрут: {{ getFlightRoute() }}</div>
                <div class="param-input">Дистанция полёта: {{ rentalData.distance }} км.</div>
            </div>
            

            <div class="param-input">
                <div>Количество топлива: {{ plane.fuel }}л / {{ plane.tankCapacity }}л</div>
            </div>
            <div class="param-checkbox">
                <label>Заправить?</label>
                <input class="checkbox" type="checkbox" v-model="isRefuel">
            </div>
            <div v-if="isRefuel">
                <div class="param-input">
                    <label>Количество топлива (л): </label>
                    <input :class="{'error-input': !refuelValidate()}" type="text" v-model="rentalData.refuel">
                </div>
                <label>Стоимость заправки: {{ refuelValidate() ? refuelCost() : 0 }}</label>
            </div>
            <div class="param-checkbox" v-if="plane.condition !== 'EXCELLENT'">
                <label>Провести ТО?</label>
                <input class="checkbox" type="checkbox" v-model="rentalData.maintenance">
            </div>
            <label>Стоимость ТО: {{ rentalData.maintenanceCost }}</label>
            <div class="center">
                <button :disabled="!(refuelValidate() && isArrivalIcaoValid && isDepartureIcaoValid)" @click="rent">
                    Арендовать самолёт
                </button>
            </div>
        </section>
    </Form>
</template>

<style scoped>
h1 {
    text-align: center;
    margin: 0 100px 10px 100px;
}

.param-input {
    display: grid;
    grid-template-columns: auto 1fr;
    gap: 10px;
    align-items: center;
    margin-bottom: 20px;
}

.param-input-button {
    display: grid;
    grid-template-columns: auto auto auto;
    gap: 10px;
    align-items: center;
    justify-content: start;
    margin-top: 5px;
}

.param-checkbox {
    display: grid;
    grid-template-columns: auto auto;
    gap: 10px;
    align-items: center;
    justify-content: start;
    margin-top: 5px;
}

.info-label {
    margin-bottom: 10px;
}

.error-input {
    border-color: red;
}

button {
    box-sizing: border-box;
}
</style>