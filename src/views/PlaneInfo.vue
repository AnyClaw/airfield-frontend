<script setup>
import axios from 'axios';
import { useRoute, useRouter } from 'vue-router'
import Footer from '@/components/Footer.vue';
import Header from '@/components/Header.vue';
import { onMounted, ref } from 'vue';

const route = useRoute()
const router = useRouter()

const isLoading = ref(true)
const plane = ref(null)

async function getPlane() {
    isLoading.value = true

    try {
        const response = await axios.get(`http://localhost:8080/planes/${route.params.id}`)
        plane.value = response.data
    }
    catch(error) {
        console.log(error)
        alert('error')
    }

    isLoading.value = false
}

function getFuel() {
    if (plane.value.fuel === 0) return `${plane.value.fuel} л. (необходима заправка)`

    return `${plane.value.fuel} л.`
}

function getCondition() {
    if (plane.value.condition === 'POOR') return `${plane.value.condition} (необходимо ТО)`
    if (plane.value.condition === 'FAIR') return `${plane.value.condition} (рекомендуется ТО)`

    return plane.value.condition
}

function rent() {
    router.push({name: 'NewRental', params: {planeId: plane.value.id}})
}

onMounted(() => {
    getPlane()
})
</script>

<template>
    <body v-if="!isLoading" class="page">
        <Header/>
        <main class="main">
            <div class="name-and-status">
                <h1 class="plane-name">{{ plane.name }}</h1>
                <div class="plane-status">
                    <span :class="{'status-free': plane.isAvailable == true, 'status-busy': plane.isAvailable == false}">
                        {{ plane.isAvailable ? "свободен" : "занят" }}
                    </span>
                </div>
            </div>
            <div class="plane-content">
                <div class="specs-section">
                    <h2 class="section-title">Характеристики</h2>

                    <div class="specs-list">
                        <div class="spec-item">
                            <span class="spec-label">Рейтинг:</span>
                            <span class="spec-value">{{ plane.rating }}</span>
                        </div>

                        <div class="spec-item">
                            <span class="spec-label">Стоимость аренды:</span>
                            <span class="spec-value">{{ plane.rentalCost }} руб / 1 км.</span>
                        </div>

                        <div class="spec-item">
                            <span class="spec-label">Расход топлива:</span>
                            <span class="spec-value">{{ plane.fuelConsumption }} л. / 1000 км.</span>
                        </div>

                        <div class="spec-item">
                            <span class="spec-label">Объём бака:</span>
                            <span class="spec-value">{{ plane.tankCapacity }} л</span>
                        </div>

                        <div class="spec-item">
                            <span class="spec-label">Стоимость ТО:</span>
                            <span class="spec-value">{{ plane.maintenanceCost }} руб.</span>
                        </div>
                    </div>
                </div>

                <div class="image-section">
                    <img src="/plane-3.jpg" class="plane-photo">
                </div>

                <div class="status-section">
                    <h2 class="section-title">Состояние</h2>

                    <div class="status-list">
                        <div class="status-item">
                            <span class="status-label">Состояние:</span>
                            <span class="status-value">{{ plane.condition }}</span>
                            <span class="status-note">{{ plane.condition === 'POOR' ? 'требуется ТО' : 'ТО не требуется' }}</span>
                        </div>

                        <div class="status-item">
                            <span class="status-label">Пробег:</span>
                            <span class="status-value">{{ plane.mileage }} км.</span>
                        </div>

                        <div class="status-item" :class="{'warning': plane.fuel == 0}">
                            <span class="status-label">Количество топлива:</span>
                            <span class="status-value">{{ plane.fuel }} л.</span>
                            <span v-if="plane.fuel == 0" class="status-note">необходима заправка</span>
                        </div>
                    </div>

                    <div class="rent-section">
                        <button class="rent-button" v-show="plane.isAvailable" @click="rent">Арендовать</button>
                    </div>
                </div>
            </div>
        </main>
        <Footer></Footer>
    </body>
</template>

<style scoped>
.main {
    max-width: 1200px;
    margin: 0 auto;
    padding: 25px;
    margin-bottom: 50px;
}

.name-and-status {
    margin-bottom: 25px;
}

.plane-name {
    text-align: center;
    font-size: 32px;
    font-weight: 700;
    color: #fff;
    margin-bottom: 10px;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5);
}

.plane-status {
    text-align: center;
}

.status-free {
    display: inline-block;
    background-color: #4CAF50;
    color: white;
    padding: 6px 16px;
    border-radius: 4px;
    font-weight: bold;
    font-size: 14px;
}

.status-busy {
    display: inline-block;
    background-color: #a72828;
    color: white;
    padding: 6px 16px;
    border-radius: 4px;
    font-weight: bold;
    font-size: 14px;
}

.plane-content {
    display: grid;
    grid-template-columns: 1fr 2fr 1fr;
    gap: 40px;
    background: white;
    padding: 40px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.section-title {
    font-size: 24px;
    font-weight: bold;
    color: #1E90FF;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 2px solid #eee;
}

.specs-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.spec-item {
    padding: 12px;
    background: #f8f9fa;
    border-left: 4px solid #1E90FF;
    border-radius: 4px;
}

.spec-label {
    display: block;
    font-weight: bold;
    color: #555;
    margin-bottom: 4px;
    font-size: 14px;
}

.spec-value {
    font-size: 18px;
    font-weight: bold;
    color: #222;
}

.spec-note {
    display: block;
    font-size: 12px;
    color: #777;
    margin-top: 4px;
}

.image-section {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
}

.plane-photo {
    width: 100%;
    height: auto;
    max-height: 400px;
    object-fit: contain;
    display: block;
    border-radius: 8px;
    border: 2px solid #ddd;
}

.status-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
    margin-bottom: 30px;
}

.status-item {
    padding: 12px;
    background: #f8f9fa;
    border-radius: 4px;
    border-left: 4px solid #1E90FF;
}

.status-item.warning {
    border-left-color: #ff9800;
    background: #fff8e1;
}

.status-label {
    display: block;
    font-weight: bold;
    color: #555;
    margin-bottom: 4px;
    font-size: 14px;
}

.status-value {
    font-size: 18px;
    font-weight: bold;
    color: #222;
}

.status-item.warning .status-value {
    color: #d32f2f;
}

.status-note {
    display: block;
    font-size: 12px;
    color: #777;
    margin-top: 4px;
}

.rent-section {
    text-align: center;
    padding-top: 20px;
    border-top: 1px solid #eee;
}

.rent-button {
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

.rent-button:hover {
    background-color: #0066CC;
}
</style>