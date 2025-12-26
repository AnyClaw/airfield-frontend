<script setup>
import Header from '@/components/Header.vue';
import Footer from '@/components/Footer.vue';
import { useRouter } from 'vue-router';
import { ref, onMounted } from 'vue';
import axios from 'axios';

const router = useRouter()
const rentals = ref()

const isLoading = ref(true)

async function getRentals() {
    const token = localStorage.getItem('authToken')

    if (!token) {
        router.push({ name: 'Login' })
        return
    }

    try {
        const response = await axios.get('http://localhost:8080/accountant/rentals', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })

        rentals.value = response.data
    } catch (error) {
        if (error.response?.status === 401) {
            localStorage.removeItem('authToken');
            router.push({ name: 'Login' });
        }
        if (error.response?.status === 403) {
            router.push({name: 'Planes'})
        }
        else console.log(error)
    }

    isLoading.value = false
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

function getCurrentWaypoint(rental) {
    const stage = rental.currentStage

    if (stage == rental.route.length)
        return rental.route[stage - 1].toWaypoint.name

    return rental.route[stage].fromWaypoint.name
}

onMounted(() => {
    getRentals()
})
</script>

<template>
    <body class="page">
        <Header></Header>
        <main class="main" v-if="!isLoading">
            <h1 class="accounting-title">История аренд для бухгалтерии</h1>

            <ul class="history-list">
                <li v-for="rental in rentals">
                    <article class="card">
                        <div class="card-header">
                            <div class="card-header-left">
                                <span class="rental-id">ID: {{ rental.id }}</span>
                            </div>
                            <div class="card-header-center">
                                <span :class="{ 
                                        'status-active': rental.status === 'ACTIVE',
                                        'status-rented': rental.status === 'RENTED',
                                        'status-awaiting': rental.status === 'AWAITING_PAYMENT',
                                        'status-completed': rental.status === 'COMPLETED'
                                    }" class="rental-status">
                                    {{ rental.status }}
                                </span>
                            </div>
                            <div class="card-header-right">
                                <span class="user-info">{{ rental.pilot.name }}</span>
                            </div>
                        </div>
                        <div class="card-main-information">
                            <div class="flight-route">
                                <div class="airport">
                                    <span class="airport-name">{{ rental.arrivalAirport.name }}</span>
                                    <span class="airport-code">{{ rental.arrivalAirport.icao }}</span>
                                </div>
                                <div class="route-arrow">→</div>
                                <div class="airport">
                                    <span class="airport-name">{{ rental.departureAirport.name }}</span>
                                    <span class="airport-code">{{ rental.departureAirport.icao }}</span>
                                </div>
                            </div>
                            <div class="rental-details">
                                <div class="detail-item">
                                    <span class="detail-label">Самолёт:</span>
                                    <span class="detail-value">{{ rental.plane.name }}</span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Начало аренды:</span>
                                    <span class="detail-value">{{ formatDateToDDMMYYYY(rental.startTime) }}</span>
                                </div>
                                <div v-if="rental.status === 'ACTIVE'" class="detail-item">
                                    <span class="detail-label">Текущая точка:</span>
                                    <span class="detail-value">{{ getCurrentWaypoint(rental) }}</span>
                                </div>
                                <div v-if="rental.status === 'AWAITING_PAYMENT' || rental.status === 'COMPLETED'" class="detail-item">
                                    <span class="detail-label">Конец аренды:</span>
                                    <span class="detail-value">{{ formatDateToDDMMYYYY(rental.endTime) }}</span>
                                </div>
                            </div>
                            <div class="financial-info">
                                <h2 class="financial-title">Финансы</h2>
                                <div class="financial-item">
                                    <span>Аренда:</span>
                                    <span class="detail-value cost">{{ rental.plane.rentalCost }} руб. / 1 км.</span>
                                </div>
                                <div class="financial-item">
                                    <span>Топливо:</span>
                                    <span>{{ rental.refuelCost }} руб.</span>
                                </div>
                                <div v-if="rental.status === 'AWAITING_PAYMENT' || rental.status === 'COMPLETED'" class="financial-item">
                                    <span>Итого:</span>
                                    <span class="detail-value cost">{{ rental.totalCost }} руб.</span>
                                </div>
                            </div>
                        </div>
                    </article>
                </li>
            </ul>
        </main>
    </body>

    <Footer></Footer>
</template>

<style scoped>
.main {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 30px;
    margin: 50px auto;
    font-size: 18px;
    max-width: 1200px;
    width: 95%;
}

.accounting-title {
    text-align: center;
    font-size: 32px;
    font-weight: bold;
    color: #fff;
    margin-bottom: 30px;
    padding-bottom: 15px;
    text-transform: uppercase;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.7);
}

.history-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
    width: 100%;
}

.card {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 10px;
    border: 2px solid #1E3C72;
    overflow: hidden;
    transition: all 0.3s ease;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.card:hover {
    transform: translateY(-5px);
    border-color: #1E90FF;
    box-shadow: 0 8px 20px rgba(30, 144, 255, 0.2);
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 20px;
    background: #e8f4ff;
    border-bottom: 1px solid #dee2e6;
}

.card-header-left {
    flex: 1;
    text-align: left;
}

.card-header-center {
    flex: 1;
    text-align: center;
}

.card-header-right {
    flex: 1;
    text-align: right;
}

.rental-id {
    font-weight: 600;
    color: #1E3C72;
    font-size: 16px;
    background: white;
    padding: 4px 12px;
    border-radius: 4px;
    border: 1px solid #1E90FF;
    display: inline-block;
}

.rental-status {
    text-transform: uppercase;
    border-radius: 20px;
    padding: 6px 15px;
    font-size: 14px;
    font-weight: 700;
    display: inline-block;
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

.user-info {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    display: inline-block;
}

.card-main-information {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    padding: 20px;
    gap: 20px;
}

.flight-route {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    border: 1px solid #dee2e6;
}

.airport {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.airport-name {
    font-weight: 600;
    color: #333;
    margin-bottom: 5px;
    font-size: 16px;
}

.airport-code {
    font-size: 14px;
    color: #666;
    background: #dee2e6;
    padding: 2px 8px;
    border-radius: 4px;
}

.route-arrow {
    font-size: 24px;
    color: #1E90FF;
    margin: 0 15px;
}

.rental-details {
    display: flex;
    flex-direction: column;
    gap: 15px;
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    border: 1px solid #dee2e6;
}

.detail-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px dashed #dee2e6;
}

.detail-item:last-child {
    border-bottom: none;
}

.detail-label {
    font-size: 14px;
    color: #666;
}

.detail-value {
    font-size: 16px;
    font-weight: 600;
    color: #333;
}

.detail-value.cost {
    color: #28a745;
    font-size: 18px;
    font-weight: 700;
}

.financial-info {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    border: 1px solid #dee2e6;
}

.financial-title {
    font-size: 16px;
    font-weight: 600;
    color: #1E3C72;
    margin-bottom: 15px;
    text-align: center;
    text-transform: uppercase;
}

.financial-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px dashed #dee2e6;
}

.financial-item:last-child {
    border-bottom: none;
}

@media (max-width: 768px) {
    .details-main {
        grid-template-columns: 1fr;
    }
    
    .details-header {
        flex-direction: column;
        gap: 10px;
        text-align: center;
    }
}
</style>