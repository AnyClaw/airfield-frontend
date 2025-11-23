<script setup>
import { useRouter } from 'vue-router'

const user = localStorage.getItem('authToken')

const router = useRouter()

function exit() {
    localStorage.removeItem('authToken')
    alert("Вы вышли из системы")
    location.reload()
}
</script>

<template>
    <header>
        <router-link to="/planes">
            <img src="/nano_banana.png" width="150px"></img>
        </router-link>

        <div v-if="user == null" class="user-links">
            <router-link to="/login" class="link">
                    Войти
            </router-link>
            <router-link to="/register" class="link">
                Зарегестрироваться
            </router-link>
        </div>
            
        <div v-else class="user-links">
            <router-link to="/profile" class="link">
                Профиль
            </router-link>
            <div class="link" @click="exit">
                Выйти
            </div>
        </div>
    </header>
</template>

<style scoped>
header {
    background-color: white;
    border-bottom: 5px solid rgb(113 188 227);
    display: flex;
    justify-content: space-between;
}

.user-links {
    min-width: 100px;
    padding: 10px;
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    margin-right: 10px;
}

.link {
    width: 100%;
    text-align: center;
    text-decoration: none;
    color: black;
    cursor: pointer;
    border: 1px solid silver;
    border-radius: 5px;
    margin-bottom: 5px;
    padding: 5px;
}

.link:hover {
    background-color: silver;
}
</style>