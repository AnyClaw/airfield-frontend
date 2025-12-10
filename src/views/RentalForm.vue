<script setup>
import Header from '@/components/Header.vue';
import Form from '@/components/Form.vue';
import { onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';

const route = useRoute()
const router = useRouter()

const plane = ref()
const profile = ref()

const rentalData = ref({
    time: 0,
    refuel: 0,
    maintenance: false
})
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
    } catch(error) {
        if (error.response?.status === 401) {
            localStorage.removeItem('authToken');
            router.push({name: 'Login'});
        }
        else console.log(error)
    }
}

function timeValidate() {
    const time = Number(rentalData.value.time)

    if (isNaN(time)) {
        return false
    }

    return time > 0
}

function refuelValidate() {
    const refuel = Number(rentalData.value.refuel)
    const totalFuel = plane.value.fuel

    if (isNaN(refuel)) {
        return false
    }

    return refuel >= 0 && refuel + totalFuel <= plane.value.tankCapacity
}

function calculateCost() {
    var cost = plane.value.rentalCost * rentalData.value.time

    if (isRefuel.value && refuelValidate()) {
        cost += 100 * rentalData.value.refuel
    }

    if (rentalData.value.maintenance) {
        const maintenanceCost = {
            "EXCELLENT": 0,
            "GOOD": 1,
            "FAIR": 2,
            "POOR": 3
        }

        cost += plane.value.maintenanceCost * maintenanceCost[plane.value.condition]
    }

    return cost
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
        <section v-if="!isLoading" class="content">
            <div class="info-label">
                Самолёт: <label style="cursor: pointer;">{{ plane.name }}</label>
            </div>
            <div class="info-label">Состояние: {{ plane.condition }}</div>
            <div class="param-input">
                <div>Время полёта (ч):</div>
                <input :class="{'error-input': !timeValidate()}" type="text" v-model="rentalData.time">
            </div>
            <div class="param-input">
                <div>Количество топлива: {{ plane.fuel }}л / {{ plane.tankCapacity }}л</div>
            </div>
            <div class="param-checkbox">
                <label>Заправить?</label>
                <input class="checkbox" type="checkbox" v-model="isRefuel">
            </div>
            <div class="param-input" v-if="isRefuel">
                <label>Количество топлива (л): </label>
                <input :class="{'error-input': !refuelValidate()}" type="text" v-model="rentalData.refuel">
            </div>
            <div class="param-checkbox" v-if="plane.condition !== 'EXCELLENT'">
                <label>Провести ТО?</label>
                <input class="checkbox" type="checkbox" v-model="rentalData.maintenance">
            </div>
            <div class="total-section">
                Итого: {{ calculateCost() }}
            </div>
            <label>Ваш баланс: {{ profile.balance }}</label>
            <div class="center">
            <button :disabled="!(refuelValidate() && timeValidate())">Арендовать самолёт</button>
        </div>
        </section>
    </Form>
    {{ rentalData }}
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
}

.param-checkbox {
    display: grid;
    grid-template-columns: auto auto;
    gap: 10px;
    align-items: center;
    justify-content: start;
    margin-top: 5px;
}

.total-section {
    font-size: large;
    font-weight: bold;
    margin-top: 10px;
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