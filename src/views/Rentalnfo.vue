<script setup>
import Header from '@/components/Header.vue';
import axios from 'axios';
import { onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';

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
        flightRoute.value = getFlightRoute()
    }
    catch (error) {
        alert('error')
        console.log(error)
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
        const response = await axios.post(`http://localhost:8080/rental/start/${rental.value.id}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        rental.value = response.data
    } catch(error) {
        alert('error')
        console.log(error)
    }
}

onMounted(() => {
    getRental()
})
</script>

<template>
    <Header></Header>

    <main>
        <h1>Информация об аренде</h1>
        <section class="content">
            <div class="rental-section" v-if="!isLoading">
                <div>Самолёт: {{ rental.plane.name }}</div>
                <div>
                    Аэропорт вылета: {{ rental.arrivalAirport.icao + " " + rental.arrivalAirport.name }}
                </div>
                <div>
                    Аэропорт прилёта: {{ rental.departureAirport.icao + " " + rental.departureAirport.name }}
                </div>
                <div>Маршрут: {{ flightRoute }}</div>

                <div v-if="rental.status === 'ACTIVE'">Текущая точка: #</div>
                <div v-if="rental.status === 'COMPLETED'">Время аренды: #</div>

                <div>
                    Количество топлива: {{ rental.plane.fuel + "л. / " + rental.plane.tankCapacity + "л."}}
                </div>
                <div>
                    Состояние самолёта: {{ rental.plane.condition }}
                </div>

                <div v-if="rental.status === 'RENTED'" class="next-section">
                    <div>Стоимость дозаправки: {{ rental.refuelCost }}</div>
                    <div>Стоимость ТО: {{ rental.maintenanceCost }}</div>
                    <button @click="startFlight">Начать полёт</button>
                </div>

                <div v-if="rental.status === 'ACTIVE'" class="next-section">

                </div>
            </div>
            <div class="map-section">
                <img src="/map-example.jpg"/>
            </div>
        </section>
    </main>
</template>

<style scoped>
h1 {
    text-align: center;
    padding: 10px;
    border-bottom: 2px solid silver;
}

.content {
    display: grid;
    grid-template-columns: 1fr 1fr;
    margin-top: 20px;
}

.map-section {
    display: flex;
    justify-content: center;
}

.rental-section {
    padding: 10px;
}

.next-section {
    margin-top: 10px;
}
</style>