<script setup>
import axios from 'axios';
import { useRoute, useRouter } from 'vue-router'

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
    router.push({name: 'NewRental', params: {id: plane.value.id}})
}

onMounted(() => {
    getPlane()
})
</script>

<template>
    <Header/>
    <main v-if="!isLoading">
        <section class="name-section">
            <h1>{{ plane.name }}</h1>
            <span>{{ plane.isAvailable ? "свободен" : "занят" }}</span>
        </section>

        <section class="content">
            <div class="info-block main-info">
                <div>Рейтинг: {{ plane.rating }} / 5.0</div>
                <div>Стоимость аренды: {{ plane.rentalCost }} руб/ч</div>
                <div>Расход топлива: {{ plane.fuelConsumption }} л/ч</div>
                <div>Дальность полёта при полной заправке: #</div>
                <div>Объём бака: {{ plane.tankCapacity }} л.</div>
                <div>Стоимость ТО: {{ plane.maintenanceCost }} руб</div>
            </div>

            <div class="main-section">
                <img src="/airplane-example.png">
                <div class="info-block">
                    <div>Состояние: {{ getCondition() }}</div>
                    <div>Часы налета: {{ plane.mileage }} ч</div>
                    <div>Количество топлива: {{ getFuel() }}</div>
                    <div>Дальность полёта при текущей заправке: #</div>
                </div>
            </div>
        </section>

        <section class="center rent-section">
            <button :disabled="!plane.isAvailable" @click="rent">Арендовать</button>
        </section>
    </main>
</template>

<style scoped>
.name-section {
    display: flex;
    flex-direction: column;
    width: 100%;
    margin-bottom: 10px;
    border: 2px solid silver;
    padding: 10px;
    text-align: center;
    box-sizing: border-box;
}

.content {
    display: grid;
    grid-template-columns: 30% 70%;
    padding: 20px;
}

.main-section {
    display: flex;
    align-items: center;
    flex-direction: column;
}

.main-section img {
    margin-bottom: 20px;
    width: 100%;
    max-width: 400px;
}

.info-block {
    width: 100%;
    padding: 10px;
    box-sizing: border-box;
}

.info-block * {
    margin-bottom: 1%;
}

.main-info {
    border: 2px solid silver;
    border-radius: 5px;
}

.rent-section {
    margin: 20px 0  ;
}

.rent-section button {
    font-size: 40px;
}
</style>