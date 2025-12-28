<script setup>
import Header from '@/components/Header.vue';
import Footer from '@/components/Footer.vue';
import { useRouter } from 'vue-router';
import { ref, onMounted } from 'vue';
import axios from 'axios';

const router = useRouter()

const profile = ref()
const rentals = ref()

const isLoading = ref(true)

async function checkToken() {
    const token = localStorage.getItem('authToken')

    if (!token) {
        router.push({ name: 'Login' })
        return
    }

    try {
        const response = await axios.get('http://localhost:8080/pilot/profile', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })

        profile.value = response.data
        findRentals(token)
    } catch (error) {
        if (error.response?.status === 401) {
            localStorage.removeItem('authToken');
            router.push({ name: 'Login' });
        }
        else console.log(error)
    }

    isLoading.value = false
}

async function findRentals(token) {
    try {
        const response = await axios.get(`http://localhost:8080/rentals/${profile.value.user.id}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        rentals.value = response.data
    }
    catch (error) {
        alert('error')
        console.log(error)
    }
}

function goToRentalInfo(rental) {
    router.push({name: 'Rental', params: {id: rental.id}})
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
    checkToken()
})
</script>

<template>
    <body class="page" v-if="!isLoading">
        <Header />
        <main class="main">
            <div class="profile">
                <img src="/nano-banana-new-logo-bez-fona.png" alt="стандартное фото в профиле пилота" class="profile-photo">
                <div>
                    <h1 class="pilot-name">{{ profile.user.name }}</h1>
                    <span class="status-pilot">Pilot</span>
                    <ul class="profile-information">
                        <li>
                            <span>Логин:</span>
                            <span>{{ profile.user.login }}</span>
                        </li>
                        <li>
                            <span>Лицензия:</span>
                            <span>{{ profile.license }}</span>
                        </li>
                        <li>
                            <span>Часы налёта:</span>
                            <span>{{ profile.mileage }}</span>
                        </li>
                        <li>
                            <span>Баланс:</span>
                            <span>{{ profile.balance }}</span>
                        </li>
                        <button class="balance-button">Пополнить баланс</button>
                    </ul>
                </div>
            </div>
            <div class="rental-history">
                <h2 class="history-title">История аренд</h2>
                <ul class="history-list">
                    <li v-for="rental in rentals" @click="goToRentalInfo(rental)">
                        <article class="card">
                            <div class="card-header">
                                <div class="card-header-plane-info">
                                    <div class="plane-icon">✈</div>
                                    <p class="plane-name">{{ rental.plane.name }}</p>
                                </div>
                                <div :class="{ 
                                        'status-active': rental.status === 'ACTIVE',
                                        'status-rented': rental.status === 'RENTED',
                                        'status-awaiting': rental.status === 'AWAITING_PAYMENT',
                                        'status-completed': rental.status === 'COMPLETED'
                                    }" class="rental-status">
                                    {{ rental.status }}
                                </div>
                            </div>
                            <section class="card-main-information">
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
                                        <span class="detail-label">Начало аренды:</span>
                                        <span class="detail-value">{{ formatDateToDDMMYYYY(rental.startTime) }}</span>
                                    </div>

                                    <div v-if="rental.status === 'RENTED'" class="detail-item">
                                        <span class="detail-label">Стоимость дозаправки:</span>
                                        <span class="detail-value">{{ rental.refuelCost }}</span>
                                    </div>

                                    <div v-if="rental.status === 'RENTED'" class="detail-item">
                                        <span class="detail-label">Стоимость ТО:</span>
                                        <span class="detail-value">{{ rental.maintenanceCost }}</span>
                                    </div>

                                    <div v-if="rental.status === 'ACTIVE'" class="detail-item">
                                        <span class="detail-label">Текущая точка:</span>
                                        <span class="detail-value">{{ getCurrentWaypoint(rental) }}</span>
                                    </div>

                                    <div v-if="rental.status === 'AWAITING_PAYMENT' || rental.status === 'COMPLETED'" class="detail-item">
                                        <span class="detail-label">Конец аренды:</span>
                                        <span class="detail-value">{{ formatDateToDDMMYYYY(rental.startTime) }}</span>
                                    </div>

                                    <div v-if="rental.status === 'AWAITING_PAYMENT' || rental.status === 'COMPLETED'" class="detail-item">
                                        <span class="detail-label">Стоимость аренды:</span>
                                        <span class="detail-value">{{ rental.totalCost }} руб.</span>
                                    </div>
                                </div>
                            </section>
                        </article>
                    </li>
                </ul>
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
    gap: 30px;
    margin-top: 50px;
    margin-bottom: 50px;
    font-size: 18px;
}

.profile {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: 30px;
    width: 70%;
    min-height: 300px;
    border: 2px solid #808080;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
    border-radius: 12px;
    position: relative;
    overflow: hidden;
    background-image: url(/zadnii-fon-profile.jpg);
    background-position: center;
    background-size: cover;
}

.profile-photo {
    width: 100%;
    height: 100%;
    background-position: center;
    background-size: cover;
}

.pilot-name {
    text-align: center;
}

.status-pilot {
    display: block;
    text-align: center;
    text-transform: uppercase;
    font-size: 20px;
    font-weight: 600;
}

.profile-information {
    margin-top: 30px;
    display: flex;
    flex-direction: column;
    gap: 25px;
}

.profile-information li {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 0;
    padding-right: 15px;
    border-bottom: 2px dotted #ddd;
    position: relative;
}

.profile-information li span:first-child {
    font-weight: 600;
    color: #2c3e50;
    font-size: 18px;
    position: relative;
    padding-left: 25px;
}

.profile-information li span:first-child::before {
    content: '▶';
    position: absolute;
    left: 0;
    color: #1E90FF;
    font-size: 14px;
}

.profile-information li:nth-child(4) span:last-child {
    font-size: 24px;
    font-weight: 700;
    color: #27ae60;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.1);
}

.balance-button {
    width: fit-content;
    min-height: 45px;
    cursor: pointer;
    border: none;
    background-color: #1E90FF;
    color: #fff;
    border-radius: 8px;
    transition: all 0.3s ease;
    font-size: 18px;
    font-weight: 600;
    padding: 12px 30px;
}

.balance-button:hover {
    transform: scale(1.1);
}


.rental-history {
    width: 70%;
    background: white;
    border-radius: 12px;
    border: 2px solid #808080;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    padding: 30px;
}

.history-title {
    font-size: 24px;
    font-weight: bold;
    color: #1E3C72;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 2px solid #1E90FF;
    text-align: center;
}

.history-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.history-list li {
    cursor: pointer;
}

.card {
    background: #f8f9fa;
    border-radius: 10px;
    border: 1px solid #dee2e6;
    overflow: hidden;
    transition: all 0.3s ease;
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px 20px;
    background: #e8f4ff;
    border-bottom: 1px solid #dee2e6;
}

.card-header-plane-info {
    display: flex;
    align-items: center;
    gap: 15px;
}

.plane-icon {
    font-size: 24px;
}

.plane-name {
    font-size: 20px;
    font-weight: 700;
    color: #1E3C72;
}

.rental-status {
    text-transform: uppercase;
    border-radius: 20px;
    padding: 6px 15px;
    font-size: 14px;
    font-weight: 700;
}

.status-rented {
    background-color: rgb(208, 208, 0);
    color: black;
}

.status-active {
    background-color: #28a745;
    color: #fff;
}

.status-completed {
    background: #6c757d;
    color: white;
}

.status-awaiting {
    background-color: #a72828;
    color: #fff;
}

.card-main-information {
    display: grid;
    grid-template-columns: 1fr 1fr;
    padding: 20px;
    gap: 20px;
}

.flight-route {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #fff;
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
    font-weight: 700;
    color: #333;
    margin-bottom: 5px;
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
}

.detail-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    border-bottom: 1px dashed #dee2e6;
}

.detail-label {
    font-size: 14px;
    color: #666;
}

.cost {
    color: #28a745;
    font-size: 18px;
}

.detail-value {
    font-size: 16px;
    font-weight: bold;
    color: #333;
}
</style>