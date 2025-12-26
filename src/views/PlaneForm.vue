<script setup>
import Header from '@/components/Header.vue';
import Footer from '@/components/Footer.vue';
import { onMounted, ref } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';

const router = useRouter()
const isLoading = ref(true)

const planeData = ref({
    name: '',
    tankCapacity: 1,
    fuel: 0,
    rentalCost: 0,
    fuelConsumption: 1,
    maintenanceCost: 0,
    condition: 'EXCELLENT',
    mileage: 0
})

const conditionOptions = [
    { value: 'EXCELLENT', label: 'EXCELLENT', color: 'status-new' },
    { value: 'GOOD', label: 'GOOD', color: 'status-excellent' },
    { value: 'FAIR', label: 'FAIR', color: 'status-good' },
    { value: 'POOR', label: 'POOR', color: 'status-fair' }
]

async function checkToken() {
    const token = localStorage.getItem('authToken')

    if (!token) {
        router.push({ name: 'Login' })
        return
    }

    try {
        await axios.get('http://localhost:8080/admin/profile', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
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

async function submitForm(event) {
    event.preventDefault();
    
    const token = localStorage.getItem('authToken')
    if (!token) {
        router.push({ name: 'Login' })
        return
    }

    console.log(planeData.value)

    try {
        const response = await axios.post('http://localhost:8080/admin/add', planeData.value, {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        })

        alert('Самолёт добавлен!')
        router.push({name: 'PlaneInfo', params: {id: response.data.id}})
    } catch(error) {
        alert('error')
        console.log(error)
    }
}

onMounted(() => {
    checkToken()
})
</script>

<template>
    <body class="page">
        <Header></Header>
        <main class="main" v-if="!isLoading">
            <form class="form-container" @submit="submitForm">
                <h1 class="form-title">Форма добавления самолёта</h1>
                <section class="basic-info-section">
                    <h2 class="section-title">Основная информация</h2>
                    <div class="input-row">
                        <h3 class="input-label">Название самолёта:</h3>
                        <input type="text" class="text-input" placeholder="Например: Су-30" v-model="planeData.name">
                    </div>
                    <div class="input-row">
                        <h3 class="input-label">Объём бака (л.):</h3>
                        <input type="number" class="number-input" placeholder="100" min="1" v-model="planeData.tankCapacity">
                    </div>
                    <div class="input-row">
                        <h3 class="input-label">Количество топлива (л.):</h3>
                        <input type="number" class="number-input" placeholder="100" min="0" :max="planeData.tankCapacity" v-model="planeData.fuel">
                    </div>
                    <div class="input-row">
                        <h3 class="input-label">Стоимость аренды (руб.):</h3>
                        <input type="number" class="number-input" placeholder="100" min="1" v-model="planeData.rentalCost">
                    </div>
                    <div class="input-row">
                        <h3 class="input-label">Расход топлива (л. / 1000 км.):</h3>
                        <input type="number" class="number-input" placeholder="100" min="1" v-model="planeData.fuelConsumption">
                    </div>
                    <div class="input-row">
                        <h3 class="input-label">Стоимость ТО (руб.):</h3>
                        <input type="number" class="number-input" placeholder="100" min="0" v-model="planeData.maintenanceCost">
                    </div>
                    <div class="input-row">
                        <h3 class="input-label">Пробег (км.):</h3>
                        <input type="number" class="number-input" placeholder="100" min="0" v-model="planeData.mileage">
                    </div>
                    <div class="condition-section">
                        <div class="condition-title">Состояние самолёта:</div>
                        <div class="radio-group">
                            <div v-for="option in conditionOptions" :key="option.value">
                                <input 
                                    type="radio" 
                                    name="condition" 
                                    :value="option.value" 
                                    :id="`condition-${option.value.toLowerCase()}`"
                                    v-model="planeData.condition"
                                >
                                <label :for="`condition-${option.value.toLowerCase()}`" class="radio-label">
                                    <span :class="option.color">{{ option.label }}</span>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="info-note">
                        После добавления самолёт будет доступен для аренды в системе. Убедитесь, что все данные указаны
                        корректно.
                    </div>
                </section>
                <button type="submit" class="action-button">Добавить самолёт</button>
            </form>
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

.basic-info-section {
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

.input-row {
    display: flex;
    align-items: center;
    margin-bottom: 20px;
    padding: 15px;
    background: white;
    border-radius: 8px;
    border: 1px solid #dee2e6;
}

.input-label {
    width: 220px;
    color: #333;
    font-weight: 600;
    font-size: 16px;
}

.text-input {
    flex: 1;
    padding: 10px 15px;
    border: 2px solid #dee2e6;
    border-radius: 6px;
    font-size: 16px;
    font-weight: 500;
    background: white;
}

.text-input:focus {
    outline: none;
    border-color: #1E90FF;
}

.number-input {
    width: 150px;
    padding: 10px 15px;
    border: 2px solid #dee2e6;
    border-radius: 6px;
    font-size: 16px;
    font-weight: 500;
    background: white;
    text-align: center;
}

.condition-section {
    margin: 20px 0;
    padding: 15px;
    background: white;
    border-radius: 8px;
    border: 1px solid #dee2e6;
}

.condition-title {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin-bottom: 15px;
}

.radio-group {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
}

.radio-label {
    display: flex;
    align-items: center;
    gap: 10px;
    cursor: pointer;
    font-weight: 500;
    color: #333;
    padding: 8px 15px;
    border-radius: 6px;
    border: 2px solid transparent;
    transition: all 0.2s ease;
}

.radio-label:hover {
    border-color: #1E90FF;
    background: #f0f8ff;
}

input[type="radio"]:checked+.radio-label {
    border-color: #1E90FF;
    background: #e8f4ff;
}

input[type="radio"] {
    display: none;
}

.status-new {
    color: #28a745;
    font-weight: 600;
    font-size: 16px;
}

.status-excellent {
    color: #28a745;
    font-weight: 600;
    font-size: 16px;
}

.status-good {
    color: #ffc107;
    font-weight: 600;
    font-size: 16px;
}

.status-fair {
    color: #fd7e14;
    font-weight: 600;
    font-size: 16px;
}

.info-note {
    font-size: 14px;
    color: #666;
    margin-top: 20px;
    font-style: italic;
    padding: 10px;
    background: #f0f8ff;
    border-radius: 6px;
    border: px solid #1E90FF;
}

.action-button {
    width: 100%;
    padding: 20px;
    background: #0066cc;
    color: white;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    font-weight: 700;
    font-size: 20px;
    margin-top: 30px;
    transition: all 0.3s ease;
    letter-spacing: 1px;
    text-transform: uppercase;
}

.action-button:hover {
    background: #0066cc;
    transform: translateY(-2px);
}

.select-input {
    flex: 1;
    padding: 10px 15px;
    border: 2px solid #dee2e6;
    border-radius: 6px;
    font-size: 16px;
    font-weight: 500;
    background: white;
    cursor: pointer;
}

.select-input:focus {
    outline: none;
    border-color: #1E90FF;
}
</style>