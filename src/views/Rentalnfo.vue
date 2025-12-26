<script setup>
import Header from '@/components/Header.vue';
import WMap from '@/components/WMap.vue';
import axios from 'axios';
import { onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import Footer from '@/components/Footer.vue';

const rental = ref()
const flightRoute = ref()

const isLoading = ref(true)
const route = useRoute()
const router = useRouter()

async function getRental() {
    const rentalId = route.params.id
    const token = localStorage.getItem('authToken')

    if (!rentalId || !token) {
        router.push({name: 'Planes'})
        return
    }

    try {
        const response = await axios.get(`http://localhost:8080/rental/${rentalId}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        rental.value = response.data
        console.log(rental.value)
        flightRoute.value = getFlightRoute()
    }
    catch (error) {
        if (error.response?.status === 401) {
            localStorage.removeItem('authToken');
            router.push({name: 'Login'});
        }
        else {
            alert('error')
            console.log(error)
        }
    }

    isLoading.value = false
}

function getFlightRoute() {
    const tempFlightRoute = rental.value.route

    if (tempFlightRoute.length == 0) return ''

    return tempFlightRoute[0].fromWaypoint.name + ", " + tempFlightRoute.map(w => w.toWaypoint.name).join(", ")
}

async function startFlight() {
    const token = localStorage.getItem('authToken')

    if (!token) {
        router.push({name: 'Planes'})
        return
    }

    try {
        const response = await axios.post(`http://localhost:8080/rental/takeoff/${rental.value.id}`, null, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        rental.value = response.data
    } catch(error) {
        if (error.response?.status === 401) {
            localStorage.removeItem('authToken');
            router.push({name: 'Login'});
        }
        else {
            alert('error')
            console.log(error)
        }
    }
}

async function nextStage() {
    const token = localStorage.getItem('authToken')

    if (!token) {
        router.push({name: 'Planes'})
        return
    }

    try {
        const response = await axios.post(`http://localhost:8080/rental/next/${rental.value.id}`, null, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        rental.value = response.data
    } catch(error) {
        if (error.response?.status === 401) {
            localStorage.removeItem('authToken');
            router.push({name: 'Login'});
        }
        else {
            alert('error')
            console.log(error)
        }
    }
}

async function finishFlight() {
    const token = localStorage.getItem('authToken')

    if (!token) {
        router.push({name: 'Planes'})
        return
    }

    try {
        const response = await axios.post(`http://localhost:8080/rental/land/${rental.value.id}`, null, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        rental.value = response.data
    } catch(error) {
        if (error.response?.status === 401) {
            localStorage.removeItem('authToken');
            router.push({name: 'Login'});
        }
        else {
            alert('error')
            console.log(error)
        }
    }
}

async function pay() {
    const token = localStorage.getItem('authToken')

    if (!token) {
        router.push({name: 'Planes'})
        return
    }

    try {
        const response = await axios.post(`http://localhost:8080/rental/pay/${rental.value.id}`, null, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        rental.value = response.data
    } catch(error) {
        if (error.response?.status === 401) {
            localStorage.removeItem('authToken');
            router.push({name: 'Login'});
        }
        else {
            alert('error')
            console.log(error)
        }
    }
}

function getCurrentWaypoint() {
    const stage = rental.value.currentStage

    if (stage == rental.value.route.length)
        return rental.value.route[stage - 1].toWaypoint.name

    return rental.value.route[stage].fromWaypoint.name
}

function getDistance() {
    const stage = rental.value.currentStage
    
    if (stage == rental.value.route.length)
        return 0

    return rental.value.route[stage].distance
}

function isFinalStage() {
    return rental.value.currentStage == rental.value.route.length
}

function formatDateToDDMMYYYY(dateString) {
    const date = new Date(dateString);
    
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    
    return `${day}.${month}.${year} ${hours}:${minutes}:${seconds}`;
}

function getTotalTime() {
    const date1 = new Date(rental.value.endTime)
    const date2 = new Date(rental.value.startTime)

    const diff = Math.abs(date2 - date1);
    
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diff % (1000 * 60)) / 1000);
    
    const parts = [];
    if (days > 0) parts.push(`${days} дн`);
    if (hours > 0) parts.push(`${hours} час`);
    if (minutes > 0) parts.push(`${minutes} мин`);
    if (seconds > 0 || parts.length === 0) parts.push(`${seconds} сек`);
    
    return parts.join(' ');
}

onMounted(() => {
    getRental()
})
</script>

<template>
    
    <body class="page" v-if="!isLoading">
        <Header></Header>
        <main class="main">
            <div class="rental-details-container">
                <div class="details-header">
                    <h2 class="details-title">Аренда #{{ rental.id }}</h2>
                    <div :class="{
                        'status-active': rental.status === 'ACTIVE',
                        'status-rented': rental.status === 'RENTED',
                        'status-awaiting': rental.status === 'AWAITING_PAYMENT',
                        'status-completed': rental.status === 'COMPLETED'
                        }" class="details-status">
                        {{ rental.status }}
                    </div>
                </div>
                <div class="details-main">
                    <div class="info-column">
                        <div class="info-section">
                            <h3 class="info-title">Основная информация</h3>

                            <div class="info-row">
                                <span class="info-label">Номер аренды:</span>
                                <span class="info-value">#{{ rental.id }}</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Самолёт:</span>
                                <span class="info-value">{{ rental.plane.name }}</span>
                            </div>

                            <div class="info-row" v-if="rental.status !== 'AWAITING_PAYMENT' && rental.status !== 'COMPLETED'">
                                <span class="info-label">Состояние самолёта:</span>
                                <span class="info-value">{{ rental.plane.condition }}</span>
                            </div>

                            <div class="info-row" v-if="rental.status !== 'AWAITING_PAYMENT' && rental.status !== 'COMPLETED'">
                                <span class="info-label">Количество топлива:</span>
                                <span class="info-value">{{ rental.plane.fuel + "л. / " + rental.plane.tankCapacity + "л."}}</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Пилот:</span>
                                <span class="info-value">{{rental.pilot.name}}</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Начало аренды:</span>
                                <span class="info-value">{{ formatDateToDDMMYYYY(rental.startTime) }}</span>
                            </div>

                            <div class="info-row" v-if="rental.status === 'AWAITING_PAYMENT' || rental.status === 'COMPLETED'">
                                <span class="info-label">Конец аренды:</span>
                                <span class="info-value">{{ formatDateToDDMMYYYY(rental.endTime) }}</span>
                            </div>

                            <div class="info-row" v-if="rental.status === 'AWAITING_PAYMENT' || rental.status === 'COMPLETED'">
                                <span class="info-label">Время аренды:</span>
                                <span class="info-value">{{ getTotalTime() }}</span>
                            </div>
                        </div>

                        <div class="info-section">
                            <h3 class="info-title">Маршрут</h3>

                            <div class="info-row">
                                <span class="info-label">Вылет из:</span>
                                <span class="info-value">{{ rental.arrivalAirport.name }} ({{ rental.arrivalAirport.icao }})</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Прилёт в:</span>
                                <span class="info-value">{{ rental.departureAirport.name }} ({{ rental.departureAirport.icao }})</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Маршрут:</span>
                                <span class="info-value">{{ flightRoute }}</span>
                            </div>

                            <div class="info-row" v-if="rental.status === 'ACTIVE'">
                                <span class="info-label">Текущая точка:</span>
                                <span class="info-value">{{ getCurrentWaypoint() }}</span>
                            </div>

                            <div class="info-row" v-if="rental.status === 'ACTIVE'">
                                <span class="info-label">Дистанция до следующей точки:</span>
                                <span class="info-value">{{ getDistance() }} км.</span>
                            </div>
                        </div>

                        <div class="info-section">
                            <h3 class="info-title">Финансовая информация</h3>

                            <div class="info-row">
                                <span class="info-label">Стоимость аренды:</span>
                                <span class="info-value cost">{{ rental.plane.rentalCost }} руб / 1 км.</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Топливо:</span>
                                <span class="info-value">{{ rental.refuelCost }} руб.</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Стоимость ТО:</span>
                                <span class="info-value">{{ rental.maintenanceCost }} руб.</span>
                            </div>

                            <div class="info-row" v-if="rental.status === 'AWAITING_PAYMENT' || rental.status === 'COMPLETED'">
                                <span class="info-label">Общая сумма:</span>
                                <span class="info-value cost">{{ rental.totalCost }} руб.</span>
                            </div>
                        </div>

                        <div v-if="rental.status === 'RENTED'">
                            <button class="button" @click="startFlight">Начать полёт</button>
                        </div>
                        <div v-if="rental.status === 'ACTIVE'">
                            <button v-if="isFinalStage()" @click="finishFlight" class="button"> Завершить полёт</button>
                            <button v-else @click="nextStage" class="button">Следующая точка</button>
                        </div>
                        <div v-if="rental.status === 'AWAITING_PAYMENT'">
                            <button @click="pay" class="button">Оплатить</button>
                        </div>
                    </div>

                    <div class="map-column">
                        <div class="map-section">
                            <h3 class="map-title">Карта маршрута</h3>
                            <div class="map-placeholder">
                                <WMap :routeData="rental.route" height="600px"></WMap>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        <Footer></Footer>
    </body>
</template>

<style scoped>
.main {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin: 50px auto;
    font-size: 18px;
    max-width: 1800px;
    width: 95%;
}

.rental-details-container {
    width: 100%;
    background: rgba(255, 255, 255, 0.95);
    border-radius: 12px;
    border: 2px solid #1E3C72;
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
    padding: 30px;
}

.details-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    padding-bottom: 15px;
    border-bottom: 2px solid #1E90FF;
}

.details-title {
    font-size: 24px;
    font-weight: bold;
    color: #1E3C72;
}

.details-status {
    padding: 6px 15px;
    border-radius: 20px;
    font-weight: 700;
    font-size: 14px;
    background-color: #28a745;
    color: #fff;
}

.status-rented {
    background-color: rgb(208, 208, 0);
    color: black;
}

.status-active {
    background-color: #28a745;
    color: #fff;
}

.status-awaiting {
    background-color: #a72828;
    color: #fff;
}

.status-completed {
    background: #6c757d;
    color: white;
}

.details-main {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 30px;
}

.info-column {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.info-section {
    background: #f8f9fa;
    border-radius: 10px;
    border: 1px solid #1E90FF;
    padding: 20px;
}

.info-title {
    font-size: 18px;
    font-weight: bold;
    color: #1E3C72;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 1px solid #dee2e6;
}

.info-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    border-bottom: 1px dashed #dee2e6;
}

.info-row:last-child {
    border-bottom: none;
}

.info-label {
    font-size: 14px;
    color: #666;
}

.info-value {
    font-size: 16px;
    font-weight: 600;
    color: #333;
}

.info-value.cost {
    color: #28a745;
}

.map-column {
    display: flex;
    flex-direction: column;
    max-height: 50%;
}

.map-section {
    border-radius: 10px;
    border: 1px solid #1E90FF;
    padding: 20px;
    flex: 1;
    display: flex;
    flex-direction: column;
}

.map-title {
    font-size: 18px;
    font-weight: bold;
    color: #1E3C72;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 1px solid #dee2e6;
}

.map-placeholder {
    width: 100%;
    flex: 1;
    border-radius: 8px;
    border: 2px dashed #ccc;
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 400px;
}

.button {
    background-color: #1E90FF;
    color: white;
    border: none;
    padding: 14px 40px;
    font-size: 18px;
    font-weight: bold;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.2s;
}

.button:hover {
    background-color: #0066CC;
}
</style>