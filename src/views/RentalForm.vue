<script setup>
import Header from '@/components/Header.vue';
import WMap from '@/components/WMap.vue';
import { onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';
import Footer from '@/components/Footer.vue';

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

    const planeId = route.params.planeId

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

async function rent(event) {
    event.preventDefault();
    try {
        const token = localStorage.getItem('authToken')
        const response = await axios.post('http://localhost:8080/rent', rentalData.value, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        alert("Самолёт арендован")
        router.push({name: 'Rental', params: {id: response.data.id}})
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
    
    <main class="page">
        <Header/>
        <main class="main" v-if="!isLoading">
            <form class="form-container" @submit="rent">
                <h1 class="form-title">Форма для аренды самолёта</h1>

                <section class="plane-info">
                    <div class="info-item">
                        <div class="info-label">Самолёт:</div>
                        <div class="info-value">{{ plane.name }}</div>
                    </div>

                    <div class="info-item">
                        <div class="info-label">Состояние:</div>
                        <div :class="{ 
                            'status-excellent': plane.condition === 'EXCELLENT' || plane.condition === 'GOOD',
                            'status-fair': plane.condition === 'FAIR',
                            'status-bad': plane.condition === 'POOR'
                        }">{{ plane.condition }}</div>
                    </div>
                </section>

                <section class="airport-section">
                    <h2 class="section-title">Аэропорты</h2>
                    <div class="airport-row">
                        <h3 class="airport-label">ICAO аэропорта вылета:</h3>
                        <input type="text" 
                            :class="{'error-input': !isArrivalIcaoValid}" 
                            class="airport-input"
                            v-model="arrivalICAO"
                            placeholder="USSS">
                        <button @click="getArrivalAirport" type="button" class="find-button">Найти аэропорт</button>
                    </div>
                    <div class="airport-row">
                        <h3 class="airport-label">ICAO аэропорта прилёта:</h3>
                        <input type="text" 
                            :class="{'error-input': !isDepartureIcaoValid}" 
                            class="airport-input"
                            v-model="departureICAO"
                            placeholder="UUEE">
                        <button @click="getDepartureAirport" type="button" class="find-button">Найти аэропорт</button>
                    </div>
                    <button type="button" class="route-button" @click="buildRoute" :disabled="!(isArrivalIcaoValid && isDepartureIcaoValid)">Построить маршрут</button>
                </section>

                <section class="marschrut-section" v-if="rentalData.flightRoute.length != 0">
                    <h2 class="section-title">Маршрут</h2>
                    <WMap :routeData="rentalData.flightRoute" height="600px"></WMap>
                </section>

                <section class="fuel-section">
                    <span class="fuel-display">Количество топлива: {{ plane.fuel }}л. / {{ plane.tankCapacity }}л.</span>
                    <div class="fuel-options">
                        <div class="option-row">
                            <div class="option-label">
                                <span>Заправить?</span>
                                <input type="checkbox" class="checkbox" v-model="isRefuel">
                            </div>
                        </div>
                        
                        <div class="airport-row" v-if="isRefuel">
                            <h3 class="airport-label">Количество топлива (л): </h3>
                            <input :class="{'airport-input-error': !refuelValidate(), 'airport-input': refuelValidate()}" type="text" v-model="rentalData.refuel">
                            <h3 class="label">(Стоимость заправки: {{ refuelValidate() ? refuelCost() : 0 }} руб.)</h3>
                        </div>

                        <div class="option-row">
                            <div class="option-label">
                                <span>Провести ТО?</span>
                                <input type="checkbox" class="checkbox" v-model="rentalData.maintenance">
                            </div>
                        </div>  

                        <div class="option-row">
                            <div class="option-label">Стоимость ТО:</div>
                            <div class="option-value">{{ plane.maintenanceCost }}</div>
                        </div>
                    </div>
                </section>
                <button :disabled="!(refuelValidate() && isArrivalIcaoValid && isDepartureIcaoValid)" type="submit" class="rent-button">Арендовать самолет</button>
            </form>
        </main>
        <Footer></Footer>
    </main>
</template>

<style scoped>
.main {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 30px;
    margin: 50px auto;
    font-size: 18px;
    max-width: 900px;
    width: 90%;
}

.form-container {
    width: 100%;
    background: rgba(255, 255, 255, 0.95);
    border-radius: 12px;
    border: 2px solid #808080;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    padding: 40px;
}

.form-title {
    text-align: center;
    font-size: 28px;
    font-weight: bold;
    color: #1E3C72;
    margin-bottom: 30px;
    padding-bottom: 15px;
    border-bottom: 2px solid #1E90FF;
    text-transform: uppercase;
}

.plane-info {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 30px;
    margin-bottom: 30px;
    padding: 20px;
    background: #f8f9fa;
    border-radius: 10px;
    border: 1px solid #1E90FF;
}

.info-item {
    display: flex;
    flex-direction: column;
}

.info-label {
    font-size: 14px;
    color: #666;
    margin-bottom: 5px;
    font-weight: 500;
    text-transform: uppercase;
}

.info-value {
    font-size: 20px;
    font-weight: bold;
    color: #333;
}

/*  */
.status-excellent {
    color: #28a745;
    background-color: #d4edda;
    padding: 6px 15px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 16px;
    display: inline-block;
    border: 1px solid #c3e6cb;
}

.status-fair {
    color: #ffc107;
    background-color: #ede9d4;
    padding: 6px 15px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 16px;
    display: inline-block;
    border: 1px solid #e6e3c3;
}

.status-bad {
    color: #fd7e14;
    background-color: #ede0d4;
    padding: 6px 15px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 16px;
    display: inline-block;
    border: 1px solid #e6d3c3;
}
/*  */

.airport-section {
    margin: 30px 0;
    padding: 25px;
    background: #f8f9fa;
    border-radius: 10px;
    border: 1px solid #1E90FF;
}

.section-title {
    font-size: 18px;
    font-weight: bold;
    color: #1E3C72;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 1px solid #dee2e6;
}

.airport-row {
    display: flex;
    align-items: center;
    margin-bottom: 20px;
    padding: 15px;
    background: #fff;
    border-radius: 8px;
    border: 1px solid #dee2e6;
}

.airport-label {
    width: 220px;
    color: #333;
    font-weight: 600;
    font-size: 16px;
}

.label {
    color: #333;
    font-weight: 600;
    font-size: 16px;
}

.airport-input {
    width: 120px;
    padding: 10px 15px;
    border: 2px solid #dee2e6;
    border-radius: 6px;
    font-size: 16px;
    font-weight: 500;
    text-transform: uppercase;
    background: #fff;
    margin-right: 20px;
}

.airport-input-error {
    width: 120px;
    padding: 10px 15px;
    border: 2px solid #ff9191;
    border-radius: 6px;
    font-size: 16px;
    font-weight: 500;
    text-transform: uppercase;
    background: #fff;
    margin-right: 20px;
}

.airport-input:focus {
    outline: none;
    border-color: #1E90FF;
}

.input-placeholder {
    color: #a0aec0;
    font-style: italic;
    font-size: 14px;
    margin-right: 15px;
}

.find-button {
    padding: 10px 25px;
    background: #1E90FF;
    color: #fff;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-weight: 600;
    font-size: 14px;
    transition: all 0.3s ease;
    white-space: nowrap;
}

.find-button:hover {
    background: #0066CC;
    transform: translateY(-1px);
}

.route-button {
    display: block;
    width: 100%;
    padding: 15px;
    background: #0066cc;
    color: #fff;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 700;
    font-size: 17px;
    margin-top: 20px;
    transition: all 0.3s ease;
    letter-spacing: 0.5px;
    text-transform: uppercase;
}

.route-button:hover {
    background: linear-gradient(135deg, #4ec02b 0%, #35a926 100%);
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(231, 76, 60, 0.2);
}

.route-button:disabled:hover {
    background: linear-gradient(135deg, #c0392b 0%, #a93226 100%);
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(231, 76, 60, 0.2);
}

.marschrut-section {
    margin: 30px 0;
    padding: 25px;
    background: #f8f9fa;
    border-radius: 10px;
    border: 1px solid #1E90FF;
}

.route-display {
    display: block;
    font-family: 'Courier New', monospace;
    font-size: 16px;
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    border: 1px solid #dee2e6;
    color: #333;
    font-weight: 500;
    margin-top: 10px;
    text-align: center;
}

.fuel-section {
    margin: 30px 0;
    padding: 25px;
    background: #f8f9fa;
    border-radius: 10px;
    border: 1px solid #1E90FF;
}

.fuel-display {
    display: block;
    font-weight: 700;
    font-size: 18px;
    margin-bottom: 25px;
    color: #333;
    padding: 15px;
    background: #fff;
    border-radius: 8px;
    border: 1px solid #dee2e6;
}

.fuel-options {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.option-row {
    display: flex;
    align-items: center;
    padding: 15px 20px;
    border-radius: 8px;
    gap: 20px;
}

.option-label {
    font-weight: 600;
    color: #333;
    font-size: 16px;
    display: flex;
    align-items: center;
    gap: 20px;
}

.option-value {
    color: #333;
    font-weight: 600;
    font-size: 18px;
}

.checkbox {
    width: 24px;
    height: 24px;
    border: 2px solid #cbd5e0;
    border-radius: 6px;
    background: white;
    cursor: pointer;
    position: relative;
    transition: all 0.3s ease;
}

.checkbox:checked {
    background: #1E90FF;
}

.checkbox:checked::after {
    content: "✓";
    position: absolute;
    color: white;
    font-size: 16px;
    font-weight: 700;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}

.rent-button {
    width: 100%;
    padding: 20px;
    background: #0066cc;
    color: white;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    font-weight: 700;
    font-size: 20px;
    margin-top: 20px;
    transition: all 0.3s ease;
    letter-spacing: 1px;
    text-transform: uppercase;
}

.rent-button:hover {
    transform: translateY(-2px);
}

.rent-button:disabled:hover {
    background: #cc0a00;
}

.error-input {
    border-color: red;
}
</style>