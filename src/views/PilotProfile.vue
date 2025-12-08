<script setup>
import Header from '@/components/Header.vue';
import { useRouter } from 'vue-router';
import { jwtDecode } from 'jwt-decode';
import { ref, onMounted } from 'vue';
import axios from 'axios';

const router = useRouter()
const profile = ref()
const isLoading = ref(true)

async function checkToken() {
    const token = localStorage.getItem('authToken')

    if (!token) {
        router.push({name: 'Login'})
        return
    }   

    try {
        const response = await axios.get('http://localhost:8080/profile', {
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

    isLoading.value = false
}

onMounted(() => {
    checkToken()
})
</script>

<template>
    <Header/>
    <section class="main-section" v-if="!isLoading">
        <div class="img-section">
            <img style="width: 100%;" src="/pilot-example.jpg">
        </div>
        <div class="info-section">
            <h1>{{ profile.name }}</h1>
            <h3>{{ profile.role }}</h3>
            <div>Логин: {{ profile.login }}</div>
            <div>Лицензия: #</div>
            <div>Часы налета: #</div>
            <div>Баланс: #</div>
            <button>Пополнить баланс</button>
        </div>
    </section>
    <section class="history-section">
        <h1>История аренд</h1>
    </section>
</template>

<style scoped>
.main-section {
    margin: 10px 15%;
    border: 5px solid silver;
    display: grid;
    grid-template-columns: 30% 70%;
    padding: 20px;
    box-sizing: border-box;
}

.info-section {
    margin-left: 30px;
}

.info-section h1, h3 {
    text-align: center;
}

.info-section h3 {
    font-weight: normal;
    margin-bottom: 20px;
    border-bottom: 1px solid silver;
}

.info-section div {
    margin-bottom: 10px;
}

.history-section {
    margin: 10px 15%;
    border: 5px solid silver;
    padding: 20px;
    box-sizing: border-box;
}

.history-section h1 {
    text-align: center;
}
</style>